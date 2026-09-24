return {
	"dlyongemallo/diffview-plus.nvim",
	version = "*",
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewFileHistory",
		"DiffviewFocusFiles",
		"DiffviewToggleFiles",
	},
	keys = {
		-- { "<leader>gr", review_pr, desc = "[g]it [r]eview PR (vs merge base)" },
		{ "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "[g]it [d]iff (working tree)" },
		-- { "<leader>gD", "<cmd>DiffviewClose<CR>", desc = "[g]it [D]iff close" },
		{ "<leader>gb", "<cmd>DiffviewFileHistory % --pin-local<CR>", desc = "[g]it [h]istory of this file" },
		-- { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "[g]it [H]istory of the repo" },
		{ "<leader>gh", "<Esc><cmd>'<,'>DiffviewFileHistory<CR>", mode = "v", desc = "[g]it [h]istory of selection" },
	},
	opts = function()
		local actions = require("diffview.actions")
		return {
			enhanced_diff_hl = true,
			-- Guarda en disco los ficheros marcados como revisados (`w`) por repo y rango.
			persist_selections = { enabled = true },
			hooks = {
				diff_buf_read = function(bufnr)
					vim.opt_local.foldlevel = 99
					vim.opt_local.foldenable = false
				end,
				diff_buf_win_enter = function(bufnr)
					vim.opt_local.foldlevel = 99
					vim.opt_local.foldenable = false
				end,
			},
			show_help_hints = false,
			-- Lado derecho = ficheros reales del working tree, así el LSP funciona
			-- sobre ellos (gd, referencias, diagnósticos) y no son buffers muertos.
			default_args = {
				DiffviewOpen = { "--imply-local" },
			},
			view = {
				-- OURS | THEIRS arriba, y el fichero resultante abajo a todo lo ancho.
				merge_tool = {
					layout = "diff3_mixed",
					disable_diagnostics = true,
					winbar_info = true,
				},
			},
			file_panel = {
				listing_style = "tree",
				tree_options = {
					-- Colapsa cadenas de carpetas con un solo hijo (src/lua/plugins).
					flatten_dirs = true,
					folder_statuses = "only_folded",
				},
				win_config = { position = "left", width = 50 },
			},
			keymaps = {
				view = {
					{ "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Cerrar Diffview" } },
					{ "n", "<C-n>", actions.select_next_entry, { desc = "Siguiente fichero" } },
					{ "n", "<C-p>", actions.select_prev_entry, { desc = "Fichero anterior" } },
					{ "n", "<tab>", false },
					{ "n", "<s-tab>", false },
					{ "n", "<leader>t", "<cmd>DiffviewFocusFiles<CR>", { desc = "Focus del panel de ficheros" } },
					{ "n", "<leader>e", false },
				},
				file_panel = {
					{ "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Cerrar Diffview" } },
					{ "n", "<C-n>", actions.select_next_entry, { desc = "Siguiente fichero" } },
					{ "n", "<C-p>", actions.select_prev_entry, { desc = "Fichero anterior" } },
					{ "n", "<tab>", false },
					{ "n", "<s-tab>", false },
					{
						"n",
						"<cr>",
						actions.focus_entry,
						{ desc = "Abrir el diff y saltar al fichero (ventana derecha)" },
					},
					-- { "n", "<leader>f", "<cmd>DiffviewFocusFiles<CR>", { desc = "Focus del panel de ficheros" } },
					-- { "n", "<leader>F", "<cmd>DiffviewToggleFiles<CR>", { desc = "Abrir/cerrar el panel de ficheros" } },
					{
						"n",
						"cc",
						function()
							vim.ui.input({ prompt = "Commit message: " }, function(msg)
								if not msg then
									return
								end
								local results = vim.system({ "git", "commit", "-m", msg }, { text = true }):wait()

								if results.code ~= 0 then
									vim.notify(
										"Commit failed with the message: \n"
											.. vim.trim(results.stdout .. "\n" .. results.stderr),
										vim.log.levels.ERROR,
										{ title = "Commit" }
									)
								else
									vim.notify(results.stdout, vim.log.levels.INFO, { title = "Commit" })
								end
							end)
						end,
					},
				},
				file_history_panel = {
					{ "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Cerrar Diffview" } },
					{ "n", "<C-n>", actions.select_next_entry, { desc = "Siguiente fichero" } },
					{ "n", "<C-p>", actions.select_prev_entry, { desc = "Fichero anterior" } },
					{ "n", "<tab>", false },
					{ "n", "<s-tab>", false },
					{
						"n",
						"<cr>",
						actions.focus_entry,
						{ desc = "Abrir el diff y saltar al fichero (ventana derecha)" },
					},
					-- { "n", "<leader>f", "<cmd>DiffviewFocusFiles<CR>", { desc = "Focus del panel de ficheros" } },
					-- { "n", "<leader>F", "<cmd>DiffviewToggleFiles<CR>", { desc = "Abrir/cerrar el panel de ficheros" } },
				},
			},
		}
	end,
}
