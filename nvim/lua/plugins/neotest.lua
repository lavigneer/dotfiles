return {
  { "nvim-neotest/neotest-jest" },
  {
    "nvim-neotest/neotest",
    opts = {
      output = { open_on_run = false },
      adapters = { "neotest-jest" },
    },
  },
}
