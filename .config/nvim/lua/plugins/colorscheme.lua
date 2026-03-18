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

			--FIX:
			-- If i delete this call the todo-comments highlight groups doesnt work
			-- But it is only with kanso themes, with kanagawa the hg works well
			-- Also if i execute := vim.cmd("colorscheme kanso-zen") manually, gets fixed
			-- I think this info might be usefull https://lazy.folke.io/spec/lazy_loading#-colorschemes
			-- I think the main issue is whith kanso theme, not todo-comments
			vim.defer_fn(require("todo-comments.config").colors, 10)
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
