return {
	"lewis6991/gitsigns.nvim",
	opts = {
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
		--Current line blame opts
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 500,
		},
		on_attach = function(bufnr)
			local gs = require("gitsigns")
			local function map(lhs, dir)
				local diff_key = dir == "next" and "]c" or "[c"
				vim.keymap.set("n", lhs, function()
					if vim.wo.diff then
						vim.cmd.normal({ diff_key, bang = true })
					else
						gs.nav_hunk(dir)
					end
				end, { buffer = bufnr, desc = dir .. " git hunk" })
			end
			map("<leader>h", "next")
			map("<leader>H", "prev")
		end,
	},
}
