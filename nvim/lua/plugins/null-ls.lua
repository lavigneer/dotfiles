return {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function()
      local nls = require("null-ls")
      return {
          sources = {
              -- nls.builtins.formatting.prettierd,
              nls.builtins.formatting.prettierd,
              nls.builtins.diagnostics.eslint_d,
              nls.builtins.diagnostics.cspell,
              nls.builtins.code_actions.cspell,
              require("typescript.extensions.null-ls.code-actions"),
          },
      }
    end,
}
