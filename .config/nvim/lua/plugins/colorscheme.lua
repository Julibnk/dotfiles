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
				minimal = false,
			})
			-- vim.cmd("colorscheme kanso-zen")

			--FIX:
			-- If i delete this call the todo-comments highlight groups doesnt work
			-- But it is only with kanso themes, with kanagawa the hg works well
			-- Also if i execute := vim.cmd("colorscheme kanso-zen") manually, gets fixed
			-- I think this info might be usefull https://lazy.folke.io/spec/lazy_loading#-colorschemes
			-- I think the main issue is whith kanso theme, not todo-comments

			-- vim.defer_fn(require("todo-comments.config").colors, 10)
		end,
	},
	{
		"vague-theme/vague.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			-- background = {
			-- 	dark = "zen",
			-- },
		},
		config = function()
			require("vague").setup({
				transparent = false, -- If true, background is not set
				bold = false, -- Disable bold globally
				italic = true, -- Disable italic globally
				on_highlights = function(hl, colors) end,
				colors = {
					bg = "#000000",
					inactiveBg = "#1c1c24",
					fg = "#cdcdcd",
					floatBorder = "#878787",
					line = "#252530",

					property = "#71B0C4", --"#c3c3d5" --ni puta idea,

					func = "#CD6058", -- #c48282",
					string = "#74A461", --"#e8b589",
					constant = "#C28163", --#C5C9C7-- "#C57D5B", --"#aeaed1",
					keyword = "#9E82A1", -- ,

					comment = "#717C7C", -- comments and line numbers
					number = "#C28163", --"#e0a363", true undefined

					builtin = "#CDA972", --"#b4d4cf", jsx bool etc
					parameter = "#7390B7", --func names, params and calls
					type = "#74B0B0", --"#9bb4bc", types objec properties

					visual = "#333738",

					error = "#d8647e",
					warning = "#f3be7c",
					hint = "#74B0B0", --"#5DC2DE",
					operator = "#90a0b5",
					search = "#405065",
					plus = "#7fa563",
					delta = "#f3be7c",
				},
			})
			vim.cmd("colorscheme vague")
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
