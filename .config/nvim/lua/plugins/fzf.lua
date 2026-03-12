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

		return {
			keymap = {
				fzf = {
					["ctrl-q"] = "select-all+accept",
				},
			},
			winopts = { width = 0.9, height = 0.9, preview = { horizontal = "right:50%" } },
			files = {
				-- no_ignore = true,-- respect ".gitignore"  by default
			},
			git = {
				bcommits = { winopts = { preview = { layout = "horizontal", horizontal = "right:70%" } } },
				commits = { winopts = { preview = { layout = "horizontal", horizontal = "right:70%" } } },
			},
			grep = {
				silent = true,
				rg_opts = '--column --no-heading --color=always --smart-case --max-columns=4096 -e -g "!.git"',
				winopts = { preview = { horizontal = "right:60%" } },
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

			builtin = {
				-- toggle_behavior   = "extend",
				title_fnamemodify = function(s)
					return s
				end,
				ueberzug_scaler = "cover",
				extensions = {
					["gif"] = nil, -- nil uses kitty protocol
					["png"] = nil,
					["jpg"] = nil,
					["jpeg"] = nil,
					["svg"] = { "chafa" },
				},
			},
		}
	end,
	keys = {
		{
			"<leader>ff",
			function()
				require("fzf-lua").files({ cwd_prompt = true })
			end,
		},

		{
			"<leader>fg",
			function()
				require("fzf-lua").live_grep()
			end,
		},
		{
			"<leader>fG",
			function()
				require("fzf-lua").grep_curbuf()
			end,
		},
		{
			"<leader><space>",
			function()
				require("fzf-lua").buffers({
					sort_lastused = true,
				})
			end,
		},
		{
			"<leader>fu",
			function()
				require("fzf-lua").undotree()
			end,
		},
		{
			"<leader>fm",
			function()
				require("fzf-lua").marks()
			end,
		},
		{
			"<leader>hh",
			function()
				local harpoon = require("harpoon")
				local fzf = require("fzf-lua")
				local list = harpoon:list()
				local items = {}
				for i = 1, list:length() do
					local item = list:get(i)
					if item and item.value and item.value ~= "" then
						table.insert(items, string.format("%d: %s", i, item.value)) -- skip empty lines if deletion didn't functional properly
					end
				end
				fzf.fzf_exec(items, {
					prompt = "Harpoon Files> ",
					winopts = {
						width = 0.6,
						height = 0.6,
					},

					fzf_opts = {
						["--preview"] = "bat --style=numbers --color=always $(echo {} | sed 's/^\\([0-9]\\+\\): //')",
					},
					actions = {
						["default"] = function(selected)
							local idx = tonumber(selected[1]:match("^(%d+):"))
							if idx then
								list:select(idx)
							end
						end,
						["ctrl-x"] = function(selected)
							local idx = tonumber(selected[1]:match("^(%d+):"))
							if idx then
								local item = list:get(idx)
								list:remove(item)
							end
						end,
					},
				})
			end,
			desc = "Harpoon FZF Menu",
		},
		{ "<leader>f.", "<cmd>FzfLua oldfiles<CR>" },
		{ "<leader>fr", "<cmd>FzfLua resume<CR>" },
		{ "<leader>fh", "<cmd>FzfLua helptags<CR>" },
		{ "<leader>fc", "<cmd>FzfLua command_history<CR>" },
		{ "<leader>fs", "<cmd>FzfLua lsp_document_symbols<CR>" },
		{ "<leader>fS", "<cmd>FzfLua lsp_workspace_symbols<CR>" },
		-- { "<leader>fq", "<cmd>FzfLua quickfix<CR>" },
		-- { "<leader>fQ", "<cmd>FzfLua quickfix_stack<CR>" },
		{
			"<leader>q",
			function()
				require("fzf-lua").diagnostics_document()
			end,
		},
		{ "<leader>Q", "<cmd>FzfLua diagnostics_workspace<CR>" },
		{ "<leader>gc", "<cmd>FzfLua git_commits<CR>" },
		{ "<leader>gb", "<cmd>FzfLua git_bcommits<CR>" },
		{ "<leader>fw", "<cmd>FzfLua grep_cword<CR>" },
		{ "<leader>fW", "<cmd>FzfLua grep_cWORD<CR>" },
	},
}
