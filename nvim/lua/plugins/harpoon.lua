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
    {
      "<A-5>",
      function()
        require("harpoon.ui").nav_file(5)
      end,
    },
    {
      "<A-6>",
      function()
        require("harpoon.ui").nav_file(6)
      end,
    },
    {
      "<A-7>",
      function()
        require("harpoon.ui").nav_file(7)
      end,
    },
    {
      "<leader>h1",
      function()
        require("harpoon.term").gotoTerminal(1)
      end,
    },
    {
      "<leader>h2",
      function()
        require("harpoon.term").gotoTerminal(2)
      end,
    },
    {
      "<leader>h3",
      function()
        require("harpoon.term").gotoTerminal(3)
      end,
    },
  },
}
