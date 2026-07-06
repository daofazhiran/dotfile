-- Gitsigns Configuration for Neovim 0.12+

local gitsigns = require("gitsigns")

-- Signs configuration: Use unicode/emoji for better visuals
local signs = {
  add          = { text = "┃" },
  change       = { text = "┃" },
  delete       = { text = "_" },
  topdelete    = { text = "‾" },
  changedelete = { text = "~" },
  untracked    = { text = "┆" },
}

-- Keymaps ──────────────────────────────────────────────────────────
local function on_attach(bufnr)
  local gs = package.loaded.gitsigns

  local function map(mode, l, r, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, l, r, opts)
  end

  -- Navigation
  map("n", "]c", function()
    if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) end
    vim.schedule(function() gs.next_hunk({ navigation_message = false }) end)
    return "<Ignore>"
  end, { expr = true, buffer = bufnr, desc = "Next git hunk" })

  map("n", "[c", function()
    if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) end
    vim.schedule(function() gs.prev_hunk({ navigation_message = false }) end)
    return "<Ignore>"
  end, { expr = true, buffer = bufnr, desc = "Previous git hunk" })

  -- Actions (normal mode)
  map("n", "<leader>hs", gs.stage_hunk, { buffer = bufnr, desc = "Stage hunk" })
  map("n", "<leader>hr", gs.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
  map("n", "<leader>hu", gs.undo_stage_hunk, { buffer = bufnr, desc = "Undo stage hunk" })
  map("n", "<leader>hp", gs.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })

  map("n", "<leader>hb", function() gs.blame_line({ full = true }) end,
    { buffer = bufnr, desc = "Blame line (full)" })

--  map("n", "<leader>hB", gs.blame, { buffer = bufnr, desc = "Toggle blame" })
  map("n", "<leader>hd", gs.diffthis, { buffer = bufnr, desc = "Diff this" })
  map("n", "<leader>hD", function() gs.diffthis("~") end,
    { buffer = bufnr, desc = "Diff this ~" })
  map("n", "<leader>hq", gs.setqflist, { buffer = bufnr, desc = "Hunks to quickfix" })

  -- Actions (visual mode)
  map("v", "<leader>hs", function()
    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
  end, { buffer = bufnr, desc = "Stage selected" })

  map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
    { buffer = bufnr, desc = "Reset selected" })

  -- Text object
  map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>",
    { buffer = bufnr, desc = "Select hunk" })
end

gitsigns.setup({
  signs = signs,

  signs_staged_enable = true,
  signs_staged = {
    add          = { text = "┃" },
    change       = { text = "┃" },
    delete       = { text = "_" },
    topdelete    = { text = "‾" },
    changedelete = { text = "~" },
  },

  -- Signs
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`

  -- Preview
  preview_config = {
    border = "rounded",
    style = "minimal",
    relative = "cursor",
    row = 0,
    col = 1,
  },

  -- Modern virtual text configuration for line blame
  current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 300,           -- Delay in ms before blame appears
    ignore_whitespace = false,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',

  -- Watcher
  watch_gitdir = {
    enable = true,
    follow_files = true,
  },

  -- Attach
  on_attach = on_attach,
  attach_to_untracked = true,

  -- Diff
  diff_opts = {
    internal = true,            -- Use Neovim's built-in diff
    algorithm = "histogram",    -- Better diff algorithm
    indent_heuristic = true,    -- Smarter indentation diffs
    linematch = 60,             -- Neovim 0.10+: line-level matching
  },
})

