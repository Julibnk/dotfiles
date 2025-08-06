return {
	"ibhagwan/fzf-lua",
	cmd = "FzfLua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	-- setup = function(opts)
	-- 	local fzf = require("fzf-lua")
	-- 	fzf.register()

	-- end,
	opts = function()
		local fzf = require("fzf-lua")
		fzf.register_ui_select()
		local actions = require("fzf-lua.actions")
		return {
			winopts = { width = 0.9, height = 0.9, preview = { horizontal = "right:50%" } },
			files = {
				-- no_ignore = true,-- respect ".gitignore"  by default
			},
			git = {
				bcommits = { winopts = { preview = { layout = "vertical", vertical = "up:70%" } } },
				commits = { winopts = { preview = { layout = "vertical", vertical = "up:70%" } } },
			},
			grep = {
				silent = true,
				rg_opts = '--column --no-heading --color=always --smart-case --max-columns=4096 -e -g "!.git"',
				hidden = true,
			},
			diagnostics = {
				-- Remove the dashed line between diagnostic items.
				severity_only = vim.diagnostic.severity.ERROR,
				actions = {
					["ctrl-e"] = {
						fn = function(_, opts)
							-- If not filtering by severity, show all diagnostics.
							if opts.severity_only then
								opts.severity_only = nil
							else
								-- Else only show errors.
								opts.severity_only = vim.diagnostic.severity.ERROR
							end
							require("fzf-lua").resume(opts)
						end,
						noclose = true,
						desc = "toggle-all-only-errors",
						header = function(opts)
							return opts.severity_only and "show all" or "show only errors"
						end,
					},
				},
			},
			-- keymap = {
			-- 	builtin = {
			-- 		["<C-/>"] = "toggle-help",
			-- 		["<C-a>"] = "toggle-fullscreen",
			-- 		["<C-i>"] = "toggle-preview",
			-- 	},
			-- 	fzf = {
			-- 		["alt-s"] = "toggle",
			-- 		["alt-a"] = "toggle-all",
			-- 		["ctrl-i"] = "toggle-preview",
			-- 	},
			-- },
		}
	end,
	keys = {
		{ "<leader>ff", "<cmd>FzfLua files cwd_prompt=true<CR>" },
		{ "<leader>fg", "<cmd>FzfLua live_grep<CR>" },
		{ "<leader>/", "<cmd>FzfLua grep_curbuf<CR>" },
		{ "<leader><space>", "<cmd>FzfLua buffers sort_mru=tru sort_lastused=true<cr>" },
		{ "<leader>f.", "<cmd>FzfLua oldfiles<CR>" },
		{ "<leader>fr", "<cmd>FzfLua resume<CR>" },
		{ "<leader>fh", "<cmd>FzfLua helptags<CR>" },
		{ "<leader>fc", "<cmd>FzfLua command_history<CR>" },
		-- { "<leader>fq", "<cmd>FzfLua quickfix<CR>" },
		-- { "<leader>fQ", "<cmd>FzfLua quickfix_stack<CR>" },
		{ "<leader>q", "<cmd>FzfLua diagnostics_document<CR>" },
		{ "<leader>Q", "<cmd>FzfLua diagnostics_workspace<CR>" },
		{ "<leader>gc", "<cmd>FzfLua git_commits<CR>" },
		{ "<leader>gb", "<cmd>FzfLua git_bcommits<CR>" },
		{ "<leader>fw", "<cmd>FzfLua grep_cword<CR>" },
		{ "<leader>fW", "<cmd>FzfLua grep_cWORD<CR>" },
	},
}
