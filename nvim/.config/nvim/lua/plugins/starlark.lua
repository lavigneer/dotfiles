return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        starlark = { "buildifier" },
        tiltfile = { "buildifier" },
      },
      formatters = {
        buildifier = {
          command = "buildifier",
          args = { "-mode", "fix", "-lint", "off" },
          stdin = true,
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bzl = { filetypes = { "starlark", "bazel", "bzl" } },
        tilt_ls = {},
      },
    },
  },
}
