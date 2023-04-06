local Util = require("lazyvim.util")

return {
    "telescope.nvim",
    dependencies = {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        config = function()
            require("telescope").load_extension("fzf")
        end,
    },
    keys = {
        { "<leader>fF", Util.telescope("files"),                      desc = "Find Files (root dir)" },
        { "<leader>ff", Util.telescope("files", { cwd = false }),     desc = "Find Files (cwd)" },
        { "<leader>sG", Util.telescope("live_grep"),                  desc = "Grep (root dir)" },
        { "<leader>sg", Util.telescope("live_grep", { cwd = false }), desc = "Grep (cwd)" },
    }
}
