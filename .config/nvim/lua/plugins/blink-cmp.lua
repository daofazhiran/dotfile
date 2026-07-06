-- lua/plugins/blink-cmp.lua
require("blink.cmp").setup({
  -- Keymaps preset: 'default' | 'super-tab' (similiar to vs-code)
  keymap = { preset = 'super-tab' },

  -- Completion Sources: Tell blink where to grab suggestions from
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
    -- Per-source configuration
    providers = {
      lsp = {
        -- Don't show LSP suggestions inside comments
        fallback_for = { 'buffer' },
      },
      buffer = {
        -- Only show buffer words after typing 3 characters (reduces noise)
        min_keyword_length = 3,
      },
    },
  },

  -- Enable signature help (shows function params while typing)
  signature = {
    enabled = true,
    window = { border = 'rounded' },
  },

  -- Completion Behavior
  completion = {
    -- Draw the menu in columns: Label on left, Kind/Icon on right
    menu = {
      auto_show = true,
      border = 'rounded',
      draw = {
        columns = {
          { "label", "label_description", gap = 1 },
          { "kind_icon", "kind" }
        },
        treesitter = true
      },
    },

    documentation = {
      auto_show = true,
      window = { border = 'rounded' },
      auto_show_delay_ms = 200
    },

    -- Ghost text (shows the rest of the word inline like GitHub Copilot)
    ghost_text = { enabled = true },
  },

  apperance = {
    -- Use nvim-cmp's color highlights if you have a theme that supports it,
    -- otherwise blink has its own native highlights.
    use_nvim_cmp_as_default = true,
    -- Set to 'mono' for icons without Nerd Font spacing
    nerd_font_variant = "mono",
  },

  -- Fuzzy matching engine settings
  fuzzy = { implementation = 'prefer_rust_with_warning' },
})

