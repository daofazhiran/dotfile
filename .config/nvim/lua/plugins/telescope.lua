local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup({
  defaults = {
    -- Prompt prefix (the 🔍 icon)
    prompt_prefix = "🔍 ",
    selection_caret = "➔ ",
    path_display = { "smart" },

    -- UI Styling
    window_blend = 0,
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        preview_width = 0.55,
        results_width = 0.8,
      },
      width = 0.9,
      height = 0.85,
    },

    -- Sorting
    sorting_strategy = "ascending",

    -- Mapping
    mappings = {
      i = { -- Insert mode
        ["<C-k>"] = actions.move_selection_previous, -- Move up
        ["<C-j>"] = actions.move_selection_next,     -- Move down
        ["<C-q>"] = actions.send_to_qflist,          -- Send to quickfix list
        ["<Esc>"] = actions.close,                   -- Close telescope
        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,
      },
      n = { -- Normal mode
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-q>"] = actions.send_to_qflist,
        ["<Esc>"] = actions.close,
        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,
      },
    },

    -- Customize ripgrep (live_grep) behavior
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",   -- Case insensitive unless uppercase is used
      "--hidden",       -- Search hidden files
      "--glob=!.git/*", -- Ignore .git directory
    },

    -- Customize find_files behavior
    find_command = {
      "fd",
      "--type=f",
      "--strip-cwd-prefix",
      "--hidden",
      "--exclude=.git",
      "--exclude=node_modules",
    },

    -- Ignore patterns
    file_ignore_patterns = {
      "node_modules/",
      ".git/",
      ".DS_Store",
      "target/",
      "dist/",
      "build/",
      "%.lock",
      ".dart_tool",
      ".fvm",
      ".codegraph",
    },

    -- Configure specific pickers
    pickers = {
      find_files = {
        hidden = true,
        theme = "dropdown",
      },
      live_grep = {
        theme = "ivy",
      },
      buffers = {
        theme = "dropdown",
        ignore_current_buffer = true,
        sort_mru = true, -- Show most recently used buffers first
      },
    },
  },
})

-- load extension only if the native build succeeded
pcall(telescope.load_extension, "fzf")

