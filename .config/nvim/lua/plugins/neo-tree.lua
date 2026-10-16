return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	cmd = "Neotree",
	keys = {
		{ "\\", "<cmd>Neotree reveal toggle<cr>", desc = "Toggle Neo-tree at current file" },
	},
	opts = {
		event_handlers = {
			{
				-- Shows relative line numbers in the Neo-tree window.
				event = "neo_tree_buffer_enter",
				handler = function()
					vim.opt_local.number = true
					vim.opt_local.relativenumber = true
				end,
			},
		},
		window = {
			mappings = {
				["h"] = "close_node",
				["l"] = "open",
			},
		},
		filesystem = {
			-- Oil handles directory buffers, so Neo-tree leaves netrw alone.
			hijack_netrw_behavior = "disabled",
			follow_current_file = { enabled = true },
			filtered_items = {
				hide_dotfiles = false,
				hide_gitignored = false,
			},
		},
	},
}
