-- CUSTOM SERVER CONFIGURATIONS / OVERRIDES
--
-- Procondition: Manual install LS as follows:
--
-- brew install lua-language-server
-- npm install -g basedpyright
-- rustup component add rust-analyzer
-- go install golang.org/x/tools/gopls@latest
-- brew install jdtls
-- brew install llvm
-- npm i -g typescript typescript-language-server
-- R: install.packages("languageserver")
--
-- For Python Stack
-- uv tool install basedpyright
-- uv tool install ruff
-- uv tool install debugpy
--
-- If a server requires customized settings, modify its schema inside the native 
-- vim.lsp.config table before enabling it. If you like the defaults, skip this step!

-- Global defaults merged into every server
vim.lsp.config("*", {
  -- nvim default lsp capabilities
  -- capabilities = vim.lsp.protocol.make_client_capabilities(),

  -- blink-cmp capabilities
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

vim.lsp.enable({
  "lua_ls",             -- lua

  "basedpyright",       -- Python
  "ruff",               -- Formatter & Linter for Python

  "rust_analyzer",      -- rust
  "gopls",              -- Go
  "dartls",             -- Dart/Flutter
  "jdtls",              -- Java
  "clangd",             -- C/C++
  "ts_ls",              -- TypeScript
  "r_language_server",  -- R
})

-- ========================================================================== --
-- 4. GLOBAL LSP HOOKS (Autocompletion, Capabilities & Keymaps)
-- ========================================================================== --
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Native LSP completion UI is disabled: blink.cmp talks to the LSP
    -- servers directly (see plugins/blink-cmp.lua). This also retires the
    -- misspelled `autTrigger` option that used to be silently ignored here.

    local opts = { buffer = args.buf }

    -- Navigation
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

    -- Information
    vim.keymap.set("n", "K",  vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

    -- Actions
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)

    -- Diagnostics
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

    -- Diagnostic styling
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = '✘',
          [vim.diagnostic.severity.WARN] = '▲',
          [vim.diagnostic.severity.HINT] = '●',
          [vim.diagnostic.severity.INFO] = '»',
        },
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { border = 'rounded', source = true },
    })

  end,

})

