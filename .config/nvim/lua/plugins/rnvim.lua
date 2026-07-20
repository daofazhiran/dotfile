-- ~/.config/nvim/lua/plugins/rnvim.lua
-- R.nvim 核心配置（含 §R 包开发工作流 的 8 键位 + browser 6 键位 + DAP 启动/继续键）
-- 部署参考：dao.of.nvim/01_r.qmd §配置详解 → §rnvim.lua

require("r").setup({
    -- ═══ R 进程 ═══
    R_app  = "radian",
    R_args = { "--quiet", "--no-save" },

    -- ═══ 外置终端 (tmux) ═══
    external_term = "tmux split-window -h -l 90",
    config_tmux = false,  -- R.nvim 默认 true 会创建自己的 tmux.conf 并 -f 强加；false 让 ~/.tmux.conf 独家负责

    -- ═══ bracketed paste（radian 多行发送必需）═══
    bracketed_paste = true,

    -- ═══ 对象浏览器 ═══
    objbr_place = "script,right",
    objbr_w = 40,

    -- ═══ 语法偏好 ═══
    pipe_version = "native",

    -- ═══ 快捷键定制 ═══
    hook = {
        on_filetype = function()
            local ft = vim.bo.filetype
            if ft == "r" or ft == "rmd" or ft == "quarto" then
                -- 标准 send 绑定
                vim.keymap.set("n", "<Enter>", "<Plug>RDSendLine",
                    { buffer = true, desc = "R: send line" })
                vim.keymap.set("v", "<Enter>", "<Plug>RSendSelection",
                    { buffer = true, desc = "R: send selection" })

                -- ─── R 包开发：devtools 6 键位 + usethis 2 键位 ───
                local function rsend(s)
                    require("r.send").cmd(s)
                end
                vim.keymap.set("n", "\\pl", function() rsend("devtools::load_all()") end,
                    { buffer = true, desc = "R: devtools::load_all" })
                vim.keymap.set("n", "\\pD", function() rsend("devtools::document()") end,
                    { buffer = true, desc = "R: devtools::document (避开 \\pd 默认 send paragraph)" })
                vim.keymap.set("n", "\\pt", function() rsend("devtools::test()") end,
                    { buffer = true, desc = "R: devtools::test (whole pkg)" })
                vim.keymap.set("n", "\\pT", function() rsend("devtools::test_active_file()") end,
                    { buffer = true, desc = "R: devtools::test_active_file" })
                vim.keymap.set("n", "\\pc", function() rsend("devtools::check()") end,
                    { buffer = true, desc = "R: devtools::check" })
                vim.keymap.set("n", "\\pi", function() rsend("devtools::install()") end,
                    { buffer = true, desc = "R: devtools::install" })

                vim.keymap.set("n", "\\pu", function()
                    vim.ui.input({ prompt = "Test name: " }, function(input)
                        if input and input ~= "" then
                            rsend(string.format('usethis::use_test("%s")', input))
                        end
                    end)
                end, { buffer = true, desc = "R: usethis::use_test" })
                vim.keymap.set("n", "\\pr", function()
                    vim.ui.input({ prompt = "R filename (no .R): " }, function(input)
                        if input and input ~= "" then
                            rsend(string.format('usethis::use_r("%s")', input))
                        end
                    end)
                end, { buffer = true, desc = "R: usethis::use_r" })

                -- ─── R 调试：browser() 与 DAP 独立命名空间 ───
                vim.keymap.set("n", "<leader>bn", function() rsend("n") end,
                    { buffer = true, desc = "R browser: step over" })
                vim.keymap.set("n", "<leader>bi", function() rsend("s") end,
                    { buffer = true, desc = "R browser: step into" })
                vim.keymap.set("n", "<leader>bo", function() rsend("f") end,
                    { buffer = true, desc = "R browser: step out" })
                vim.keymap.set("n", "<leader>bc", function() rsend("c") end,
                    { buffer = true, desc = "R browser: continue" })
                vim.keymap.set("n", "<leader>bq", function() rsend("Q") end,
                    { buffer = true, desc = "R browser: quit" })
                vim.keymap.set("n", "<leader>bw", function() rsend("where") end,
                    { buffer = true, desc = "R browser: call stack (where)" })

                local function r_dap_continue()
                    local ok, dap_r = pcall(require, "plugins.dap_r")
                    if not ok then
                        vim.notify("dap_r: 配置文件加载失败", vim.log.levels.ERROR)
                        return
                    end
                    dap_r.continue()
                end
                vim.keymap.set("n", "<leader>dd", r_dap_continue,
                    { buffer = true, desc = "R DAP: start package/continue" })
                vim.keymap.set("n", "<leader>dc", function()
                    local dap = require("dap")
                    if dap.session() then dap.continue() end
                end, { buffer = true, desc = "R DAP: continue" })
                -- DAP step/terminate buffer-local 映射（防 R.nvim 内部映射干扰）
                vim.keymap.set("n", "<leader>dn", function()
                    local dap = require("dap")
                    if dap.session() then dap.step_over() end
                end, { buffer = true, desc = "R DAP: step over" })
                vim.keymap.set("n", "<leader>di", function()
                    local dap = require("dap")
                    if dap.session() then dap.step_into() end
                end, { buffer = true, desc = "R DAP: step into" })
                vim.keymap.set("n", "<leader>do", function()
                    local dap = require("dap")
                    if dap.session() then dap.step_out() end
                end, { buffer = true, desc = "R DAP: step out" })
                vim.keymap.set("n", "<leader>dq", function()
                    local dap = require("dap")
                    if dap.session() then dap.terminate() end
                end, { buffer = true, desc = "R DAP: terminate" })
            end
        end,
    },

    -- ═══ 禁用的默认命令 ═══
    disable_cmds = {
        "RClearConsole",
        "RSPlot",
    },
})