return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	lazy = false,
	opts = {
		integrations = {
			mini = true,
			which_key = true,
		},
	},
	config = function(_, opts)
		require("catppuccin").setup(opts)
		-- load the colorscheme here
		vim.cmd([[colorscheme catppuccin]])
	end,
}
