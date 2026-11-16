-- Marca o desmarca el fichero bajo el cursor en el panel, o el fichero abierto en el diff.
local function toggle_file_mark()
	local view = require("diffview.lib").get_current_view()
	local file = view and view.infer_cur_file and view:infer_cur_file()
	if not file then
		return
	end
	local selections = require("diffview.api.selections")
	if selections.is_selected(file.path) then
		selections.deselect({ file.path })
	else
		selections.select({ file.path })
	end
end

-- Abre DiffviewOpen con el panel de ficheros abajo y en modo lista, sin tocar la config global.
local function open_diff_bottom_list(args)
	local file_panel = require("diffview.config").get_config().file_panel
	local listing_style, win_config = file_panel.listing_style, file_panel.win_config
	file_panel.listing_style = "list"
	file_panel.win_config = { position = "bottom", height = 12 }
	local ok, err = pcall(vim.cmd, "DiffviewOpen " .. (args or ""))
	file_panel.listing_style, file_panel.win_config = listing_style, win_config
	if not ok then
		error(err)
	end
end

-- Abre DiffviewOpen con el diff en una sola ventana (diff1_inline), sin tocar el layout de otras vistas.
local function open_diff_inline()
	local default = require("diffview.config").get_config().view.default
	local base_layout = default.layout
	default.layout = "diff1_inline"
	vim.cmd("DiffviewOpen")
	local view = require("diffview.lib").get_current_view()
	if not view then
		default.layout = base_layout
		return
	end

	-- Diffview lee el layout al refrescar los ficheros, así que se aplica solo mientras esta vista está activa.
	local group = vim.api.nvim_create_augroup("DiffviewInline" .. tostring(view):gsub("%W", ""), { clear = true })
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "DiffviewViewEnter",
		callback = function()
			if require("diffview.lib").get_current_view() == view then
				default.layout = "diff1_inline"
			end
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = { "DiffviewViewLeave", "DiffviewViewClosed" },
		callback = function(ev)
			default.layout = base_layout
			if ev.match == "DiffviewViewClosed" and view.closing:check() then
				vim.api.nvim_del_augroup_by_id(group)
			end
		end,
	})
end

local github_inline_ns = vim.api.nvim_create_namespace("GithubDiffInline")

-- Colores estilo Orca: rojo para lo borrado y verde oliva para lo añadido.
-- Los caracteres cambiados no llevan un color aparte, la línea entera usa el mismo.
local function set_github_diff_hl()
	vim.api.nvim_set_hl(0, "GithubDiffDelete", { bg = "#491924" })
	vim.api.nvim_set_hl(0, "GithubDiffAdd", { bg = "#465533" })
	-- El diff inline pinta con extmarks, que winhl no remapea, así que usa un namespace propio.
	vim.api.nvim_set_hl(github_inline_ns, "DiffviewDiffAdd", { link = "GithubDiffAdd" })
	vim.api.nvim_set_hl(github_inline_ns, "DiffviewDiffChange", { link = "GithubDiffAdd" })
	vim.api.nvim_set_hl(github_inline_ns, "DiffviewDiffTextInline", { link = "GithubDiffAdd" })
	vim.api.nvim_set_hl(github_inline_ns, "DiffviewDiffDelete", { link = "GithubDiffDelete" })
end

-- Pinta el lado viejo en rojo y el nuevo en verde, en vez de DiffChange azul en ambos.
local function apply_github_diff_hl(winid, ctx)
	if ctx.layout_name:match("^diff1_inline") then
		vim.api.nvim_win_set_hl_ns(winid, github_inline_ns)
		return
	end
	vim.api.nvim_win_set_hl_ns(winid, 0)
	if not ctx.layout_name:match("^diff2") then
		return
	end
	local group = ctx.symbol == "a" and "GithubDiffDelete" or "GithubDiffAdd"
	vim.opt_local.winhl = table.concat({
		"DiffAdd:" .. group,
		"DiffChange:" .. group,
		"DiffText:" .. group,
		"DiffDelete:DiffviewDiffDeleteDim",
	}, ",")
end

-- Al hacer scroll con la rueda en una ventana del diff que no es la activa, las demás no la siguen.
-- Fuerza un scroll mínimo en esa ventana para que scrollbind sincronice el resto.
local function sync_scrolled_diff_windows()
	local current = vim.api.nvim_get_current_win()
	for id in pairs(vim.v.event) do
		local win = tonumber(id)
		if win and win ~= current and vim.api.nvim_win_is_valid(win) and vim.wo[win].diff and vim.wo[win].scrollbind then
			vim.api.nvim_win_call(win, function()
				vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("<C-e><C-y>", true, true, true))
			end)
		end
	end
end

return {
	"dlyongemallo/diffview-plus.nvim",
	branch = "main",
	cmd = {
		"DiffviewOpen",
		"DiffviewOpenBottom",
		"DiffviewOpenInline",
		"DiffviewClose",
		"DiffviewFileHistory",
		"DiffviewFocusFiles",
		"DiffviewToggleFiles",
		"DiffviewPR",
		"DiffviewPRSync",
	},
	keys = {
		-- { "<leader>gr", review_pr, desc = "[g]it [r]eview PR (vs merge base)" },
		{ "<leader>gd", function() open_diff_inline() end, desc = "[g]it [d]iff (inline)" },
		{ "<leader>gD", "<cmd>DiffviewOpen<CR>", desc = "[g]it [D]iff (working tree)" },
		{ "<leader>gb", "<cmd>DiffviewFileHistory % --pin-local<CR>", desc = "[g]it [h]istory of this file" },
		-- { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "[g]it [H]istory of the repo" },
		{ "<leader>gh", "<Esc><cmd>'<,'>DiffviewFileHistory<CR>", mode = "v", desc = "[g]it [h]istory of selection" },
	},
	config = function(_, opts)
		require("diffview").setup(opts)
		set_github_diff_hl()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = set_github_diff_hl })
		vim.api.nvim_create_autocmd("WinScrolled", { callback = sync_scrolled_diff_windows })
		require("diffview-pr").setup()
		-- Como DiffviewOpen (acepta los mismos argumentos), pero con el panel de ficheros abajo y en modo lista.
		vim.api.nvim_create_user_command("DiffviewOpenBottom", function(cmd)
			open_diff_bottom_list(cmd.args)
		end, { nargs = "*" })
		-- Lo mismo que <leader>gd, para abrirlo desde fuera (nvim -c DiffviewOpenInline).
		vim.api.nvim_create_user_command("DiffviewOpenInline", open_diff_inline, {})
	end,
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
				diff_buf_win_enter = function(bufnr, winid, ctx)
					vim.opt_local.foldlevel = 99
					vim.opt_local.foldenable = false
					apply_github_diff_hl(winid, ctx)
				end,
			},
			show_help_hints = false,
			-- Lado derecho = ficheros reales del working tree, así el LSP funciona
			-- sobre ellos (gd, referencias, diagnósticos) y no son buffers muertos.
			default_args = {
				DiffviewOpen = { "--imply-local" },
			},
			view = {
				-- El historial de un fichero muestra cada diff en una sola ventana.
				file_history = { layout = "diff1_inline" },
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
					{ "n", "<C-j>", actions.select_next_entry, { desc = "Siguiente fichero" } },
					{ "n", "<C-k>", actions.select_prev_entry, { desc = "Fichero anterior" } },
					{ "n", "<tab>", false },
					{ "n", "<s-tab>", false },
					{ "n", "<leader>t", "<cmd>DiffviewFocusFiles<CR>", { desc = "Focus del panel de ficheros" } },
					{ "n", "<leader>e", false },
					{ "n", "<leader>w", toggle_file_mark, { desc = "Marcar/desmarcar el fichero como revisado" } },
				},
				file_panel = {
					{ "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Cerrar Diffview" } },
					{ "n", "<LeftRelease>", actions.select_entry, { desc = "Abrir el diff con un solo click" } },
					{ "n", "<C-j>", actions.select_next_entry, { desc = "Siguiente fichero" } },
					{ "n", "<C-k>", actions.select_prev_entry, { desc = "Fichero anterior" } },
					{ "n", "<tab>", false },
					{ "n", "<s-tab>", false },
					{
						"n",
						"<cr>",
						actions.focus_entry,
						{ desc = "Abrir el diff y saltar al fichero (ventana derecha)" },
					},
					{
						"n",
						"C",
						function()
							require("diffview-pr").clear_selections()
						end,
						{ desc = "Clear all file selections (disabled in PR views)" },
					},
					{ "n", "<leader>w", toggle_file_mark, { desc = "Marcar/desmarcar el fichero como revisado" } },
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
					{ "n", "<LeftRelease>", actions.select_entry, { desc = "Abrir el diff con un solo click" } },
					{ "n", "<C-j>", actions.select_next_entry, { desc = "Siguiente fichero" } },
					{ "n", "<C-k>", actions.select_prev_entry, { desc = "Fichero anterior" } },
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
