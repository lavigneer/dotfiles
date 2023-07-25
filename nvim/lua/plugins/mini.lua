return {
	{
		"echasnovski/mini.basics",
		config = true,
	},
	{
		"echasnovski/mini.basics",
		opts = {
			mappings = {
				option_toggle_prefix = "<leader>u",
			},
		},
		config = true,
	},
	{
		"echasnovski/mini.bracketed",
		config = true,
	},
	{
		"echasnovski/mini.bufremove",
		config = true,
		keys = {
			{
				"<leader>bd",
				function()
					require("mini.bufremove").delete(0, false)
				end,
				desc = "Delete Buffer",
			},
			{
				"<leader>bD",
				function()
					require("mini.bufremove").delete(0, true)
				end,
				desc = "Delete Buffer (Force)",
			},
		},
	},
	{
		"echasnovski/mini.comment",
		config = true,
		event = "VeryLazy",
		opts = {
			options = {
				custom_commentstring = function()
					return require("ts_context_commentstring.internal").calculate_commentstring()
						or vim.bo.commentstring
				end,
			},
		},
	},
	{
		"echasnovski/mini.completion",
		config = true,
		opts = {
			lsp_completion = {
				source_func = "omnifunc",
				auto_setup = false,
				process_items = function(items, base)
					-- Don't show 'Text' and 'Snippet' suggestions
					items = vim.tbl_filter(function(x)
						return x.kind ~= 1 and x.kind ~= 15
					end, items)
					return MiniCompletion.default_process_items(items, base)
				end,
			},
		},
	},
	{
		"echasnovski/mini.files",
		lazy = false,
		config = true,
		opts = {
			windows = {
				preview = true,
				width_preview = 80,
			},
		},
		keys = {
			{
				"<leader>e",
				function()
					require("mini.files").open(MiniFiles.get_latest_path())
					require("mini.files").trim_left()
				end,
				desc = "Open Mini Files",
			},
		},
	},
	{
		"echasnovski/mini.fuzzy",
		config = true,
	},
	{
		"echasnovski/mini.jump",
		config = true,
	},
	{
		"echasnovski/mini.move",
		config = true,
	},
	{
		"echasnovski/mini.statusline",
		config = true,
	},
	{
		"echasnovski/mini.surround",
		config = true,
	},
	{
		"echasnovski/mini.tabline",
		config = true,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
	},
}
