local dap = require('dap')

local fn = vim.fn

local lldb_path = fn.trim(fn.system("xcrun --find lldb-dap"))

dap.adapters.lldb = {
  type = 'executable',
  command = lldb_path,
  name = 'lldb'
}

-- 自动检测源文件路径与 DWARF 路径的符号链接差异，零配置
-- 覆盖：export DWARF_SOURCE_MAP="/Users/<user_name>/<src_root>:/<src_mount_point>"
local function auto_source_map()
  local override = os.getenv("DWARF_SOURCE_MAP")
  if override then
    local from, to = override:match("^([^:]+):(.+)$")
    if from and to then return { { from, to }, { to, from } } end
  end

  local cwd = fn.getcwd()
  local cwd_real = fn.resolve(cwd)
  if cwd_real ~= cwd then
    return { { cwd, cwd_real }, { cwd_real, cwd } }
  end

  local home = os.getenv("HOME") or vim.loop.os_homedir()
  local handle = vim.loop.fs_scandir(home)
  if not handle then return {} end

  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then break end
    if type == "link" then
      local link_path = home .. "/" .. name
      local target = fn.resolve(link_path)
      if target ~= link_path and (vim.startswith(cwd, target .. "/") or cwd == target) then
        return { { link_path, target }, { target, link_path } }
      end
    end
  end
  return {}
end

local lldb_config = {
  {
    name = 'Launch (lldb)',
    type = 'lldb',
    request = 'launch',
    program = function()
      return fn.input('Path to executable: ', fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    sourceMap = auto_source_map(),

    -- If need pass parameters
    -- args = function()
    --   local args_string = vim.fn.input('Arguments: ')
    --   return vim.split(args_string, ' ')
    -- end,
    args = {},

    env = function()
      local variables = {}
      for k, v in pairs(fn.environ()) do
        table.insert(variables, k .. "=" .. v)
      end
      return variables
    end,
  },
  {
    name = 'Attach to process (lldb)',
    type = 'lldb',
    request = 'attach',
    pid = require('dap.utils').pick_process,
    cwd = '${workspaceFolder}',
  },
}

dap.configurations.c = lldb_config
dap.configurations.cpp = lldb_config
dap.configurations.rust = lldb_config

