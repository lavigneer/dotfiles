return {
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      table.insert(opts.sources, nls.builtins.diagnostics.cspell)
      table.insert(opts.sources, nls.builtins.code_actions.cspell)
    end,
  },
}
