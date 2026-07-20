local M = {}
local configured = false

-- ═══ R 调试进程（自起交互 R + writeToStdin 桥）═══
-- vscDebugger 的流程控制建立在 browser() 从 stdin 读 n/c/s/f 之上：
-- adapter 通过自定义 DAP 事件 "custom"(reason="writeToStdin") 要求客户端
-- 把命令写进 R 的 stdin。nvim-dap 自己 spawn adapter 时 stdin 是 /dev/null，
-- browser() 读到 EOF 会立刻放行（表现为"断点一闪而过、进程 0 退出"）。
-- 因此这里模仿 VS Code 官方扩展：由我们 jobstart 一个 `R --interactive`
-- （pipe stdin），解析 stdout 中的 top-level/browser 提示符，
-- 在提示符出现时把队列中的命令（或 `.vsc.listenForDAP()`）写回 stdin。
local r_job = nil
local r_port = nil
local stdout_acc = ""
local write_queue = {} -- { { text=, which=("prompt"|"browser"|"topLevel"), count= } }
local prompt_timer = nil
local last_prompt_snapshot = nil

local function r_write(text)
  if not r_job then return end
  if not text:match("\n$") then text = text .. "\n" end
  pcall(vim.fn.chansend, r_job, text)
end

local function stop_r_process()
  local job = r_job
  r_job = nil
  if job then
    pcall(vim.fn.jobstop, job)
  end
end

-- 提示符出现（且 stdout 安静 60ms）后才动作；echo 的输入行后面总有文字，不会误判
local function on_r_prompt(which)
  for i, e in ipairs(write_queue) do
    if (e.which == "prompt" or e.which == which) and e.count ~= 0 then
      table.remove(write_queue, i)
      r_write(e.text)
      if e.count > 1 then
        e.count = e.count - 1
        table.insert(write_queue, 1, e)
      end
      return
    end
  end
  -- 队列空：重新进入 DAP 监听，让 workspace/REPL 调试在提示符下保持连接。
  -- 仅当 DAP 会话已初始化（避免启动阶段与手动 listen 命令重复）。
  local dap = package.loaded["dap"] and require("dap") or nil
  if dap then
    local session = dap.session()
    if session and session.initialized then
      r_write("vscDebugger::.vsc.listenForDAP(timeout=-1)\n")
    end
  end
end

local function arm_prompt_check()
  if not prompt_timer then prompt_timer = vim.uv.new_timer() end
  local snapshot = stdout_acc
  prompt_timer:stop()
  prompt_timer:start(60, 0, vim.schedule_wrap(function()
    if stdout_acc ~= snapshot then
      -- 输出还在流动；若仍以提示符结尾则重新等待安静
      if stdout_acc:match("> $") or stdout_acc:match("Browse%[%d+%]> $") then
        arm_prompt_check()
      end
      return
    end
    if stdout_acc == last_prompt_snapshot then return end
    last_prompt_snapshot = stdout_acc
    on_r_prompt(stdout_acc:match("Browse%[%d+%]> $") and "browser" or "topLevel")
  end))
end

local function on_r_stdout(_, data, _)
  stdout_acc = (stdout_acc .. table.concat(data, "\n")):sub(-400)
  if stdout_acc:match("> $") or stdout_acc:match("Browse%[%d+%]> $") then
    arm_prompt_check()
  end
end

local function start_r_process(port)
  stop_r_process()
  stdout_acc = ""
  write_queue = {}
  last_prompt_snapshot = nil
  r_job = vim.fn.jobstart({
    "R", "--interactive", "--no-save", "--quiet",
  }, {
    stdin = "pipe",
    on_stdout = on_r_stdout,
    on_exit = function(_, code, _)
      r_job = nil
      local dap = package.loaded["dap"] and require("dap") or nil
      if dap and dap.session() then
        vim.notify("dap_r: R 进程意外退出 (code " .. code .. ")", vim.log.levels.WARN)
      end
    end,
  })
  if r_job <= 0 then
    r_job = nil
    vim.notify("dap_r: 无法启动 R 进程", vim.log.levels.ERROR)
    return false
  end
  r_write(string.format(
    "vscDebugger::.vsc.listenForDAP(port=%d, host='127.0.0.1')\n", port
  ))
  return true
end

local function pick_port()
  local tcp = assert(vim.uv.new_tcp())
  assert(tcp:bind("127.0.0.1", 0))
  local port = tcp:getsockname().port
  tcp:close()
  return port
end

local function realpath(path)
  if not path or path == "" then return path end
  return vim.uv.fs_realpath(path) or path
end

local function current_file()
  return realpath(vim.api.nvim_buf_get_name(0))
end

-- 从当前 buffer 向上找 R 包根目录（含 DESCRIPTION 的目录）
local function find_r_package_root()
  local buf = vim.api.nvim_get_current_buf()
  local path = realpath(vim.api.nvim_buf_get_name(buf))
  if path == "" then return nil end
  local dir = vim.fn.fnamemodify(path, ":p:h")
  local prev = ""
  while dir ~= "/" and dir ~= prev do
    if vim.fn.filereadable(dir .. "/DESCRIPTION") == 1 then
      return realpath(dir)
    end
    prev = dir
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return nil
end

local function working_directory()
  return realpath(find_r_package_root() or vim.fn.getcwd())
end

local function package_configuration()
  local root = find_r_package_root()
  if not root then return nil end

  return {
    name = "R: debug package (load_all)",
    type = "r",
    request = "launch",
    debugMode = "workspace",
    workingDirectory = root,
    loadPackages = { root },
    allowGlobalDebugging = true,
    supportsWriteToStdinEvent = true,
  }
end

function M.continue()
  if not M.setup() then return end

  local dap = require("dap")
  local session = dap.session()
  if session then
    if not session.initialized then
      vim.notify("R DAP: 会话启动中，请稍候…", vim.log.levels.INFO)
      return
    end
    -- 仅在真正停住时才 continue。vscDebugger 不发 continued 事件，
    -- 程序跑完后 UI 仍显示最后一帧；此时盲目 continue 只会让下一次
    -- 步进报 "No stopped threads. Cannot move"，这里提前拦住并提示。
    local stopped = session.stopped_thread_id ~= nil
    if not stopped then
      for _, t in pairs(session.threads or {}) do
        if t.stopped then
          stopped = true
          break
        end
      end
    end
    if stopped then
      dap.continue()
    else
      vim.notify(
        "R DAP: 会话空闲（程序已跑完或未命中断点）。"
          .. "在 DAP REPL 重新求值（如 summarise_numeric(mtcars)）可再次命中断点；"
          .. "<Space>dq 结束会话。",
        vim.log.levels.INFO
      )
    end
    return
  end

  -- 每次启动用全新的 R 进程，避免上一个会话残留的 session 状态
  r_port = pick_port()
  if not start_r_process(r_port) then return end

  local config = package_configuration()
  if config then
    vim.fn.chdir(config.workingDirectory)
    vim.notify(
      "R DAP: package workspace " .. config.workingDirectory,
      vim.log.levels.INFO
    )
    dap.run(config)
  else
    dap.continue()
  end
end

function M.setup()
  if configured then
    return true
  end

  local ok, dap = pcall(require, "dap")
  if not ok then
    vim.notify("dap_r: nvim-dap 未加载", vim.log.levels.ERROR)
    return false
  end

  if vim.fn.executable("R") ~= 1 or vim.fn.executable("Rscript") ~= 1 then
    vim.notify("dap_r: R 或 Rscript 不在 PATH", vim.log.levels.ERROR)
    return false
  end

  -- --no-init-file：不让 ~/.Rprofile 的 stdout 输出污染 "TRUE" 判定
  local process_ok, process = pcall(vim.system, {
    "Rscript",
    "--no-init-file",
    "-e",
    "cat(requireNamespace('vscDebugger', quietly=TRUE))",
  }, { text = true })
  if not process_ok then
    vim.notify("dap_r: 无法启动 Rscript", vim.log.levels.ERROR)
    return false
  end

  -- 注意：同步等待，首次按 <Space>dd/dc 时 UI 最长阻塞 5 秒（仅一次，幂等）
  local result = process:wait(5000)
  if result.code ~= 0 or vim.trim(result.stdout or "") ~= "TRUE" then
    vim.notify("dap_r: R 包 vscDebugger 未安装或检查超时", vim.log.levels.ERROR)
    return false
  end

  -- adapter 只负责告诉 nvim-dap 连哪里；R 进程由 M.continue() 自己拉起，
  -- 等 R 开始监听后再回调（nvim-dap 连接本身还有重试兜底）
  dap.adapters.r = function(callback, _)
    vim.defer_fn(function()
      callback({
        type = "server",
        host = "127.0.0.1",
        port = r_port or 18721,
      })
    end, 400)
  end

  -- dap-ui 的窗口（Scopes/Stacks/...）不接受外来 buffer。switchbuf=uselast 时
  -- 若 alternate window 恰好是 dap-ui 窗口，nvim-dap 会把源文件塞进去、dap-ui
  -- 立刻夺回，set_cursor 落在 1 行的 dap-ui buffer 上 →
  -- "Adapter reported frame ... Invalid cursor line: out of range"。
  -- useopen 优先：源文件几乎总已在某个窗口中，直接跳那个窗口，不碰 dap-ui。
  dap.defaults.r.switchbuf = "useopen,uselast"

  -- vscDebugger 的 variables 响应会把内部 stackNode 泄漏成没有 name 的
  -- 条目（命名列表 → JSON 对象），nvim-dap-virtual-text 与 dap-ui 的
  -- variables 组件都假定每个条目有 name，直接崩溃
  -- （"table index is nil" / "attempt to concatenate field 'name'"）。
  -- 在会话边界统一过滤，两个插件同时受益。
  dap.listeners.after.event_initialized["dap_r.filterVariables"] = function(session)
    local orig_request = session.request
    session.request = function(self, command, args, on_result)
      if command ~= "variables" then
        return orig_request(self, command, args, on_result)
      end
      local function filter(err, resp)
        if resp and type(resp.variables) == "table" then
          local clean = {}
          for _, v in ipairs(resp.variables) do
            if type(v) == "table" and v.name ~= nil then
              clean[#clean + 1] = v
            end
          end
          if #clean == 0 then
            -- 泄漏情形：整个响应是 map（string keys），收集合法 Variable
            for _, v in pairs(resp.variables) do
              if type(v) == "table" and v.name ~= nil then
                clean[#clean + 1] = v
              end
            end
          end
          resp.variables = clean
        end
        if on_result then
          return on_result(err, resp)
        end
        return err, resp
      end
      if on_result then
        return orig_request(self, command, args, filter)
      end
      -- 协程同步路径（无回调）：request 内 yield，恢复后在此处继续
      return filter(orig_request(self, command, args))
    end
  end

  dap.configurations.r = {
    {
      name = "R: debug current file",
      type = "r",
      request = "launch",
      debugMode = "file",
      workingDirectory = working_directory,
      file = current_file,
      allowGlobalDebugging = true,
      supportsWriteToStdinEvent = true,
    },
    {
      name = "R: debug function in current file",
      type = "r",
      request = "launch",
      debugMode = "function",
      workingDirectory = working_directory,
      file = current_file,
      mainFunction = function()
        return vim.fn.input("Function to debug: ", "main")
      end,
      allowGlobalDebugging = true,
      supportsWriteToStdinEvent = true,
    },
    {
      name = "R: debug package (load_all)",
      type = "r",
      request = "launch",
      debugMode = "workspace",
      workingDirectory = working_directory,
      loadPackages = function()
        return { working_directory() }
      end,
      allowGlobalDebugging = true,
      supportsWriteToStdinEvent = true,
    },
  }

  -- writeToStdin 桥：vscDebugger 以 "custom" 事件（reason="writeToStdin"）
  -- 要求把流程控制命令写进 R 的 stdin；when/queue 语义对齐 VS Code 官方客户端
  dap.listeners.before.event_custom["dap_r.writeToStdin"] = function(_, body)
    if type(body) ~= "table" or body.reason ~= "writeToStdin" then return end
    local text = body.text or ""
    if body.addNewLine ~= false and not text:match("\n$") then
      text = text .. "\n"
    end
    local when = body.when or "now"
    local count = body.count or 1
    if when == "now" then
      for _ = 1, math.max(count, 1) do
        r_write(text)
      end
      return
    end
    local which = ({ browserPrompt = "browser", topLevelPrompt = "topLevel" })[when]
      or "prompt"
    if body.stack and count == 0 then
      -- ignore
    elseif body.stack then
      table.insert(write_queue, { text = text, which = which, count = count ~= 0 and count or -1 })
    elseif count == 0 then
      write_queue = {}
    else
      write_queue = { { text = text, which = which, count = count } }
    end
  end

  -- 会话结束即回收 R 进程
  dap.listeners.after.event_terminated["dap_r.cleanup"] = function()
    stop_r_process()
  end
  dap.listeners.after.event_exited["dap_r.cleanup"] = function()
    stop_r_process()
  end
  dap.listeners.after.disconnect["dap_r.cleanup"] = function()
    -- disconnectRequest 会让 vscDebugger 排队输入 quit(save="no")；兜底强杀
    vim.defer_fn(stop_r_process, 3000)
  end

  configured = true
  vim.notify("dap_r: vscDebugger adapter ready", vim.log.levels.INFO)
  return true
end

return M
