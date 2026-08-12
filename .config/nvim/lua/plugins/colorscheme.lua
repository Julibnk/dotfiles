return {
	-- {
	-- 	"webhooked/kanso.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	opts = {
	-- 		-- background = {
	-- 		-- 	dark = "zen",
	-- 		-- },
	-- 	},
	-- 	config = function()
	-- 		-- require("kanso").setup({
	-- 		-- 	foreground = {
	-- 		-- 		dark = "saturated",
	-- 		-- 		light = "saturated",
	-- 		-- 	},
	-- 		-- 	minimal = false,
	-- 		-- })
	-- 		-- vim.cmd("colorscheme kanso-zen")
	--
	-- 		--FIX:
	-- 		-- If i delete this call the todo-comments highlight groups doesnt work
	-- 		-- But it is only with kanso themes, with kanagawa the hg works well
	-- 		-- Also if i execute := vim.cmd("colorscheme kanso-zen") manually, gets fixed
	-- 		-- I think this info might be usefull https://lazy.folke.io/spec/lazy_loading#-colorschemes
	-- 		-- I think the main issue is whith kanso theme, not todo-comments
	--
	-- 		-- vim.defer_fn(require("todo-comments.config").colors, 10)
	-- 	end,
	-- },
	-- {
	-- 	"vague-theme/vague.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- opts = {
	-- 	-- background = {
	-- 	-- 	dark = "zen",
	-- 	-- },
	-- },
	-- config = function()
	-- Paleta de kitty exportada por .zshrc (KITTY_COLOR*, KITTY_FOREGROUND,
	-- KITTY_BACKGROUND). Fuente única de verdad: no duplicamos los hex.
	-- Fallback a los valores previos si la env var no está presente.
	-- local function kc(name, fallback)
	-- 	local v = vim.env["KITTY_" .. name]
	-- 	if v and v ~= "" then
	-- 		return v
	-- 	end
	-- 	return fallback
	-- end

	-- 	require("vague").setup({
	-- 		transparent = false, -- If true, background is not set
	-- 		bold = false, -- Disable bold globally
	-- 		italic = true, -- Disable italic globally
	-- 		on_highlights = function(hl, colors) end,
	-- 		colors = {
	-- 			bg = kc("BACKGROUND", "#000000"),
	-- 			inactiveBg = "#1c1c24",
	-- 			fg = kc("FOREGROUND", "#C5C9C7"),
	-- 			floatBorder = "#878787",
	-- 			line = "#252530",
	--
	-- 			property = "#71B0C4", --"#c3c3d5" --ni puta idea,
	--
	-- 			-- func = kc("COLOR1", "#CD6058"),
	-- 			func = kc("COLOR11", "#CDA972"),
	-- 			string = kc("COLOR10", "#74A461"),
	-- 			constant = kc("COLOR16", "#C2825D"),
	-- 			keyword = kc("COLOR14", "#9E82A1"),
	--
	-- 			comment = "#717C7C", -- comments and line numbers
	-- 			number = kc("COLOR16", "#C2825D"),
	--
	-- 			builtin = kc("COLOR11", "#CDA972"),
	-- 			parameter = "#7390B7", --func names, params and calls
	-- 			type = kc("COLOR12", "#74B0B0"),
	--
	-- 			visual = "#333738",
	--
	-- 			error = "#d8647e",
	-- 			warning = "#f3be7c",
	-- 			hint = kc("COLOR12", "#74B0B0"),
	-- 			operator = "#90a0b5",
	-- 			search = "#405065",
	-- 			plus = "#7fa563",
	-- 			delta = "#f3be7c",
	-- 		},
	-- 	})
	-- 	vim.cmd("colorscheme vague")
	-- end,
	-- },
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			-- vim.cmd("colorscheme kanagawa")
		end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
		config = function()
			-- vim.cmd("colorscheme tokyonight-moon")
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		config = function()
			vim.cmd("colorscheme catppuccin-mocha")
		end,
		priority = 1000,
	},
}
