return {
  "folke/zen-mode.nvim",
  keys = {
    {
      "<leader>uz",
      function()
        require("zen-mode").toggle()
      end,
      desc = "Toggle zen mode",
    },
  },
}
