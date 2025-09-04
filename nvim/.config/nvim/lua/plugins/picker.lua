return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader><space>",
        function()
          Snacks.picker.buffers({ hidden = true, nofile = true })
        end,
        desc = "Find Files (Root Dir)",
      },
      { "<leader>sf", LazyVim.pick("files", { cmd = "rg", hidden = true, root = false }), desc = "Find Files (Root Dir)" },
      { "<leader>sg", LazyVim.pick("live_grep", { cmd = "rg", hidden = true, root = false }), desc = "Grep (Root Dir)" },
    },
  },
}
