return {
    {
        "nvimtools/none-ls.nvim",
        opts = function(_, opts)
            local nls = require("none-ls")
            table.insert(opts.sources, nls.builtins.formatting.ocamlformat)
        end,
    },
}
