local actions = require("diffview.actions")

require("diffview").setup({
  diff_binaries = false,

  enhance_diff_hl = true,
  use_icons = true,
  watch_index = true,

  view = {
    default = {
      layout = "diff2_horizontal",
      disable_diagnostics = true, --  Turn off LSP diagnostics
      winbar_info = false,
    },
    merge_tool = {
      layout = "diff3_horizontal",
      disable_diagnostics = true, --  Turn off LSP diagnostics
      winbar_info = true,
    },
    file_history = {
      layout = "diff2_horizontal",
      disable_diagnostics = true, --  Turn off LSP diagnostics
      winbar_info = false,
    },

    file_panel = {
      listing_style = "tree",
      tree_options = {
        flatten_dirs = true,
        folder_statuses = "only_folded",
      },
      win_config = {
        position = "left",
        width = 40,
      },
    },

    file_history_panel = {
      log_options = {
        git = {
          single_file = {
            diff_merges = "combined",
          },
          multi_file = {
            diff_merges = "first-parent",
          },
        },
      },
      win_config = {
        position = "bottom",
        height = 16,
        win_opts = {},
      },
    },
  },
})
