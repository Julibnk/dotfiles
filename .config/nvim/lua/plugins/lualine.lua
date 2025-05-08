return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", "bwpge/lualine-pretty-path" },
	opts = {
		options = {
			icons_enabled = true,
			theme = "auto",
			component_separators = { left = "", right = "" },
			section_separators = { left = "", right = "" },
			disabled_filetypes = {
				statusline = {},
				winbar = {},
			},
			ignore_focus = {},
			always_divide_middle = true,
			always_show_tabline = true,
			globalstatus = false,
			refresh = {
				statusline = 100,
				tabline = 100,
				winbar = 100,
			},
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diagnostics" },
			lualine_c = { { "pretty_path", directories = {
				max_depth = 4,
			} } },
			lualine_x = { "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = { "filename" },
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},
		tabline = {},
		winbar = {},
		inactive_winbar = {},
		extensions = {},
	},

	-- opts = {
	-- 	sections = {
	-- lualine_a = {
	-- 	{
	-- 		"mode",
	-- 		fmt = trunc(130, 3, 0, true),
	-- 	},
	-- },
	-- lualine_b = {
	-- 	{
	-- 		"branch",
	-- 		fmt = trunc(70, 15, 65, true),
	-- 		separator = "",
	-- 	},
	--
	-- 	{
	-- 		"diff",
	-- 		symbols = {
	-- 			added = " ",
	-- 			modified = " ",
	-- 			removed = " ",
	-- 		},
	-- 		fmt = trunc(0, 0, 60, true),
	-- 	},
	-- 	{
	-- 		"diagnostics",
	-- 		-- symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
	-- 		symbols = { error = " ", warn = " ", info = " ", hint = " " },
	-- 	},
	-- },
	-- lualine_c = {
	-- 	{
	-- 		"pretty_path",
	-- 		providers = {
	-- 			-- default = require 'util/pretty_path_harpoon',
	-- 		},
	-- 		directories = {
	-- 			max_depth = 4,
	-- 		},
	-- 		highlights = {
	-- 			newfile = "LazyProgressDone",
	-- 		},
	-- 		separator = "",
	-- 	},
	-- },
	-- lualine_x = {
	-- 	{
	-- 		lazy_status.updates,
	-- 		cond = lazy_status.has_updates,
	-- 		color = { fg = "#ff9e64" },
	-- 		fmt = trunc(0, 0, 160, true), -- hide when window is < 100 columns
	-- 		separator = "",
	-- 	},
	--
	-- 	-- require('util.lualine').cmp_source('supermaven', '󰰣'),
	--
	-- 	{
	-- 		lsp_status_all,
	-- 		fmt = trunc(0, 8, 140, false),
	-- 		separator = "",
	-- 	},
	-- 	{
	-- 		encoding_only_if_not_utf8,
	-- 		fmt = trunc(0, 0, 140, true), -- hide when window is < 80 columns
	-- 		separator = "",
	-- 	},
	-- 	{
	-- 		fileformat_only_if_not_unix,
	-- 		fmt = trunc(0, 0, 140, true), -- hide when window is < 80 columns
	-- 		separator = "",
	-- 	},
	-- },
	-- lualine_y = {
	-- 	{ "progress", fmt = trunc(0, 0, 40, true) },
	-- },
	-- lualine_z = {
	-- 	{ "location", fmt = trunc(0, 0, 80, true) },
	-- },
	-- 	},
	-- },
}
