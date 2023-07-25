return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
    end,
    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)
        wk.register(opts.defaults)
    end,
    opts = {
        defaults = {
            mode = { "n", "v" },
            ["<leader>h"] = { name = "+harpoon" },
            ["<leader>b"] = { name = "+buffer" },
            ["<leader>c"] = { name = "+code" },
            ["<leader>s"] = { name = "+search" },
            ["<leader>w"] = { name = "+window" },
            ["<leader>f"] = { name = "+file" },
            ["<leader>q"] = { name = "+quit" },
            ["<leader>t"] = { name = "+test" },
            ["<leader>u"] = { name = "+ui" },
        },
    },
}
