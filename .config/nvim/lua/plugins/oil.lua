return {
	"stevearc/oil.nvim",
	keys = function()
		local oil = require("oil")
		return {
			{
				"-",
				function()
					oil.open(nil, { preview = { vertical = true, split = "belowright" } })
				end,
				desc = "Open Oil",
			},
			-- { "-", "<cmd>Oil<cr>", desc = "Open Oil" },
		}
	end,
	opts = {
		default_file_explorer = true,
		keymaps = {
			["h"] = { "actions.parent" },
			["-"] = { "actions.close" },
			["l"] = { "actions.select" },
		},
		view_options = {
			-- Show files and directories that start with "."
			show_hidden = true,
		},
	},
}
