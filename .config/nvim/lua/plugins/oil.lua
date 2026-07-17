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
			["<C-p>"] = { "actions.preview" },
			["<C-h>"] = false,
			["<C-l>"] = false,
		},
		view_options = {
			show_hidden = true,
		},
		-- Preview window auto-updates as the cursor moves; on a directory it
		-- shows the inner folder's contents.
		preview_win = {
			update_on_cursor_moved = true,
			preview_method = "fast_scratch",
		},
	},
	config = function(_, opts)
		require("oil").setup(opts)
		-- Auto-open the preview side when entering an Oil buffer.
		-- oil has no native "auto-open preview" option, so we hook OilEnter.
		-- Defer with vim.schedule and guard on get_cursor_entry(): OilEnter can
		-- fire before the buffer is rendered, and open_preview() silently bails
		-- when there's no entry under the cursor (that's the flaky behaviour).
		local oil = require("oil")
		vim.api.nvim_create_autocmd("User", {
			pattern = "OilEnter",
			callback = function(args)
				vim.schedule(function()
					-- Still on the same oil buffer, and it has actually rendered.
					if vim.api.nvim_get_current_buf() ~= args.data.buf then
						return
					end
					if not oil.get_cursor_entry() then
						return
					end
					-- "belowright" forces the preview to the right side,
					-- regardless of the global 'splitright' option.
					oil.open_preview({ split = "belowright" })
				end)
			end,
		})
	end,
}
