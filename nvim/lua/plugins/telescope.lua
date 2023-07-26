return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		{ "nvim-telescope/telescope-ui-select.nvim" },
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			config = function()
				require("telescope").load_extension("fzf")
			end,
		},
	},
	commit = vim.fn.has("nvim-0.9.0") == 0 and "057ee0f8783" or nil,
	version = false, -- telescope did only one release, so use HEAD for now
	lazy = false,
	keys = {
		-- find
		{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
		{ "<leader>ff", "<cmd>Telescope git_files<cr>", desc = "Find Files" },
		{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
		-- search
		{ "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
		{ "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
		{ "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Grep" },
	},
	config = function(_, opts)
		require("telescope").setup({
			defaults = {
				prompt_prefix = " ",
				selection_caret = " ",
				mappings = {
					n = {
						["q"] = function(...)
							return require("telescope.actions").close(...)
						end,
					},
				},
			},
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_cursor({}),
				},
			},
		})
		require("telescope").load_extension("ui-select")
	end,
}
