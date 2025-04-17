return {
	"ibhagwan/fzf-lua",
	cmd = "FzfLua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {},
	keys = {
		{ "<leader>ff", "<cmd>FzfLua files cwd_prompt=true<CR>" },
		{
			"<leader>fF",
			function()
				local fzf = require("fzf-lua")
				-- fzf.pi
			end,
		}, --'<cmd>FzfLua files root=false<CR>'}, --TODO: set root = false
		{ "<leader>/", "<cmd>FzfLua live_grep<CR>" },
		{ "<leader><space>", "<cmd>FzfLua buffers sort_mru=tru sort_lastused=true<cr>" },

		{ "<leader>f.", "<cmd>FzfLua oldfiles<CR>" },
		{ "<leader>fr", "<cmd>FzfLua resume<CR>" },
		{ "<leader>fg", "<cmd>FzfLua gitfiles<CR>" },
	},
}
