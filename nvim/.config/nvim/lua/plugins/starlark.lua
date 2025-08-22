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
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.diagnostics.buildifier.with({
          filetypes = { "starlark", "bazel", "bzl", "tiltfile" },
        })
      })
    end,
  },
}
