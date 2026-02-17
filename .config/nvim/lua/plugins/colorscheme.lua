return {
	{
		"webhooked/kanso.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			-- background = {
			-- 	dark = "zen",
			-- },
		},
		config = function()
			require("kanso").setup({
				foreground = {
					dark = "saturated",
					light = "saturated",
				},
				minimal = true,
			})
			vim.cmd("colorscheme kanso-zen")
		end,
	},
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			-- vim.cmd("colorscheme kanagawa")
		end,
	},
}
