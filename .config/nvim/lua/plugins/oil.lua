function _G.get_oil_winbar()
	local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
	local dir = require("oil").get_current_dir(bufnr)
	if dir then
		return vim.fn.fnamemodify(dir, ":~")
	end
	-- no current dir (e.g. over ssh): fall back to the buffer name
	return vim.api.nvim_buf_get_name(bufnr)
end

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
		win_options = {
			winbar = "%!v:lua.get_oil_winbar()",
		},
		keymaps = {
			["h"] = { "actions.parent" },
			["-"] = { "actions.close" },
			["l"] = { "actions.select" },
			["<C-h>"] = false,
			["<C-l>"] = false,
			["<C-p>"] = { "actions.preview", opts = { split = "belowright" } },
		},
		view_options = {
			show_hidden = true,
		},
	},
}
