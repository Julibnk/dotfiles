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
	init = function()
		-- Hides Neo-tree in Diffview tabs, which have their own file panel.
		vim.api.nvim_create_autocmd("User", {
			pattern = "DiffviewViewEnter",
			callback = function()
				if package.loaded["neo-tree"] then
					vim.cmd("Neotree close")
				end
			end,
		})
	end,
	---@module "neo-tree"
	---@type neotree.Config?
	opts = {
		default_component_configs = {
			indent = {
				-- Hides the vertical guide lines and keeps the fold arrows on folders.
				with_markers = false,
				with_expanders = true,
			},
		},
		-- Renders the icon, the name and its markers, without git status or metadata columns.
		renderers = {
			directory = {
				{ "indent" },
				{ "icon" },
				{ "current_filter" },
				{
					"container",
					content = {
						{ "name", zindex = 10 },
						{ "symlink_target", zindex = 10, highlight = "NeoTreeSymbolicLinkTarget" },
						{ "clipboard", zindex = 10 },
						{ "diagnostics", errors_only = true, zindex = 20, align = "right", hide_when_expanded = true },
					},
				},
			},
			file = {
				{ "indent" },
				{ "icon" },
				{
					"container",
					content = {
						{ "name", zindex = 10 },
						{ "symlink_target", zindex = 10, highlight = "NeoTreeSymbolicLinkTarget" },
						{ "clipboard", zindex = 10 },
						{ "bufnr", zindex = 10 },
						{ "modified", zindex = 20, align = "right" },
						{ "diagnostics", zindex = 20, align = "right" },
					},
				},
			},
		},
		window = {
			position = "right",
			width = 50,
			mappings = {
				["h"] = "close_node",
				["l"] = "open",
				-- A single click opens files and folds or unfolds folders.
				["<LeftRelease>"] = "open",
			},
		},
		filesystem = {
			-- Oil handles directory buffers, so Neo-tree leaves netrw alone.
			hijack_netrw_behavior = "disabled",
			filtered_items = {
				hide_dotfiles = false,
				hide_gitignored = false,
			},
		},
	},
}
