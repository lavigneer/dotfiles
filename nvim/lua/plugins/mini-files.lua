return {
  "echasnovski/mini.files",
  opts = {
    options = {
      use_as_default_explorer = true,
    },
    windows = {
      width_nofocus = 15,
      width_focus = 50,
      width_preview = 80,
    },
  },
  keys = {
    {
      "<leader>e",
      function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
      end,
      desc = "Open mini.files (directory of current file)",
    },
    {
      "<leader>E",
      function()
        require("mini.files").open(vim.loop.cwd(), true)
      end,
      desc = "Open mini.files (cwd)",
    },
  },
}
