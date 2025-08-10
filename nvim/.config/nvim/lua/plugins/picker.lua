return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader><space>", LazyVim.pick("files", { cmd = "rg", hidden = true }), desc = "Find Files (Root Dir)" },
      { "<leader>sf", LazyVim.pick("files", { cmd = "rg", hidden = true }), desc = "Find Files (Root Dir)" },
      { "<leader>sg", LazyVim.pick("live_grep", { cmd = "rg", hidden = true }), desc = "Grep (Root Dir)" },
    },
  },
}
