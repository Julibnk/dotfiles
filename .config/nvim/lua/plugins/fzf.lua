return {
	"ibhagwan/fzf-lua",
	cmd = "FzfLua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	-- setup = function(opts)
	-- 	local fzf = require("fzf-lua")
	-- 	fzf.register()
	-- end,
	opts = {
		winopts = { width = 0.9, height = 0.9, preview = { horizontal = "right:50%" } },
		files = {
			-- no_ignore = true,-- respect ".gitignore"  by default
		},
		git = {
			bcommits = { winopts = { preview = { layout = "vertical", vertical = "up:70%" } } },
			commits = { winopts = { preview = { layout = "vertical", vertical = "up:70%" } } },
		},
	},
	keys = {
		{ "<leader>ff", "<cmd>FzfLua files cwd_prompt=true<CR>" },
		{
			"<leader>fF",
			function()
				local fzf = require("fzf-lua")
				-- fzf.pi
			end,
		}, --'<cmd>FzfLua files root=false<CR>'}, --TODO: set root = false
		{ "<leader>fg", "<cmd>FzfLua live_grep<CR>" },
		-- { "<leader>/", "<cmd>FzfLua grep_curbuf<CR>" },
		{
			--TODO: sort results ascending
			"<leader>fb",
			function()
				require("fzf-lua").grep_curbuf({
					winopts = {
						width = 0.7,
						preview = { layout = "vertical", vertical = "down:70%" },
					},
				})
			end,
			desc = "Grep current buffer",
		},
		{ "<leader><space>", "<cmd>FzfLua buffers sort_mru=tru sort_lastused=true<cr>" },
		{ "<leader>f.", "<cmd>FzfLua oldfiles<CR>" },
		{ "<leader>fr", "<cmd>FzfLua resume<CR>" },
		{ "<leader>fh", "<cmd>FzfLua helptags<CR>" },
		{ "<leader>fc", "<cmd>FzfLua command_history<CR>" },
		{ "<leader>q", "<cmd>FzfLua diagnostics_document<CR>" },
		{ "<leader>gc", "<cmd>FzfLua git_commits<CR>" },
		{ "<leader>gb", "<cmd>FzfLua git_bcommits<CR>" },
	},
}
