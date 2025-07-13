return {
	"NvChad/nvim-colorizer.lua",
	opts = {
		-- filetypes = { "*" },
		user_default_options = {
			RGB = true, -- #RGB
			RRGGBB = true, -- #RRGGBB
			names = false, -- "blue"
			RRGGBBAA = true, -- #RRGGBBAA
			AARRGGBB = true, -- 0xAARRGGBB ← important
			mode = "background", -- or "foreground"
			css = true,
			css_fn = true,
			tailwind = true,
			sass = { enable = true, parsers = { "css" } },
		},
	},
	config = function(_, opts)
		require("colorizer").setup(opts)
	end,
}
