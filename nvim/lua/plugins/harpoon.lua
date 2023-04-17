return {
  "ThePrimeagen/harpoon",
  opts = {
    lazy = false,
  },
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    {
      "<leader>a",
      function()
        require("harpoon.mark").add_file()
      end,
      desc = "Harpoon Add File",
    },
    {
      "<C-e>",
      function()
        require("harpoon.ui").toggle_quick_menu()
      end,
      desc = "Harpoon Quick Menu",
    },

    {
      "<A-1>",
      function()
        require("harpoon.ui").nav_file(1)
      end,
    },
    {
      "<A-2>",
      function()
        require("harpoon.ui").nav_file(2)
      end,
    },
    {
      "<A-3>",
      function()
        require("harpoon.ui").nav_file(3)
      end,
    },
    {
      "<A-4>",
      function()
        require("harpoon.ui").nav_file(4)
      end,
    },
  },
}
