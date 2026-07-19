local M = {}
local configured = false

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

  dap.adapters.r = {
    type = "server",
    host = "127.0.0.1",
    port = "${port}",
    executable = {
      command = "R",
      args = {
        "--slave",
        "--no-save",
        "--no-restore",
        "--no-init-file", -- DAP R 不读 ~/.Rprofile，防 stdout 污染协议启动
        "-e",
        "vscDebugger::.vsc.listenForDAP(port=${port}, host='127.0.0.1')",
      },
    },
  }

  dap.configurations.r = {
    {
      name = "R: debug current file",
      type = "r",
      request = "launch",
      debugMode = "file",
      workingDirectory = "${workspaceFolder}",
      file = "${file}",
      allowGlobalDebugging = true,
    },
    {
      name = "R: debug function in current file",
      type = "r",
      request = "launch",
      debugMode = "function",
      workingDirectory = "${workspaceFolder}",
      file = "${file}",
      -- nvim-dap 允许配置字段为函数，启动时求值
      mainFunction = function()
        return vim.fn.input("Function to debug: ", "main")
      end,
      allowGlobalDebugging = true,
    },
    {
      name = "R: debug package (load_all)",
      type = "r",
      request = "launch",
      debugMode = "workspace",
      workingDirectory = "${workspaceFolder}",
      -- 注意：loadPackages 依赖 R 包 pkgload（装 devtools 已间接带入）
      loadPackages = { "${workspaceFolder}" },
      allowGlobalDebugging = true,
    },
  }

  configured = true
  vim.notify("dap_r: vscDebugger adapter ready", vim.log.levels.INFO)
  return true
end

return M
