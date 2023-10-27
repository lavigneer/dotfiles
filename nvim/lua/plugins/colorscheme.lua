return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = true,
      on_colors = function(colors)
        colors.fg_gutter = "#707cb2"
        colors.comment = "#709db2"
        colors.dark5 = "#709db2"
      end,
      on_highlights = function(hl, colors)
        hl.CursorLineNr = {
          fg = colors.yellow,
        }
      end,
    },
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000",
    },
  },
  { "rose-pine/neovim", name = "rose-pine" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
