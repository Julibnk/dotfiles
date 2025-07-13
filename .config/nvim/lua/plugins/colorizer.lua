--FIX: RRGGBBA with sketchybar status colors doesnt work
return {
	"norcalli/nvim-colorizer.lua",
	enabled = false,
	---@module 'colorizer'
	opts = {
		filetypes = {
			"*",
		},
		user_default_options = {
			RRGGBBAA = true,
		},
	},
}
