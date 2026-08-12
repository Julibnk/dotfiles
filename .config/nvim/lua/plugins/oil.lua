return {
	"stevearc/oil.nvim",
	keys = function()
		local oil = require("oil")
		return {
			{
				"-",
				function()
					oil.open(nil, {})
				end,
				desc = "Open Oil",
			},
			-- { "-", "<cmd>Oil<cr>", desc = "Open Oil" },
		}
	end,
	---@class oil.Config
	opts = {
		default_file_explorer = true,
		keymaps = {
			["h"] = { "actions.parent" },
			["-"] = { "actions.close" },
			["l"] = { "actions.select" },
			["<C-h>"] = false,
			["<C-l>"] = false,
		},
		view_options = {
			show_hidden = true,
		},
	},
}
