-- Abre ficheros en el editor de Orca con `orca file open`, que deduce el worktree por el cwd.
local M = {}

--- Abre un fichero en Orca, opcionalmente en una línea y columna (1-based).
---@param path string
---@param line? integer
---@param col? integer
---@param focus? boolean lleva la ventana de Orca hasta el fichero
function M.open_file(path, line, col, focus)
	if vim.fn.executable("orca") == 0 then
		vim.notify("No se encuentra el CLI de orca; ¿estás en un terminal de Orca?", vim.log.levels.WARN)
		return
	end

	local cmd = { "orca", "file", "open", vim.fn.fnamemodify(path, ":p"), "--json" }
	if line and line > 0 then
		vim.list_extend(cmd, { "--line", tostring(line) })
		if col and col > 0 then
			vim.list_extend(cmd, { "--column", tostring(col) })
		end
	end
	if focus ~= false then
		table.insert(cmd, "--focus")
	end

	vim.system(cmd, { text = true }, function(result)
		if result.code ~= 0 then
			local message = vim.trim(result.stderr ~= "" and result.stderr or result.stdout)
			vim.schedule(function()
				vim.notify("orca file open falló: " .. message, vim.log.levels.ERROR)
			end)
		end
	end)
end

--- Abre en Orca el buffer actual en la posición del cursor.
function M.open_cursor_position()
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		vim.notify("El buffer no tiene fichero", vim.log.levels.WARN)
		return
	end
	local cursor = vim.api.nvim_win_get_cursor(0)
	M.open_file(path, cursor[1], cursor[2] + 1)
end

--- Acción de fzf-lua: abre en Orca las entradas elegidas y lleva el foco a la última.
---@param selected string[]
---@param opts table
function M.open_fzf_selection(selected, opts)
	local fzf_path = require("fzf-lua.path")
	for index, entry in ipairs(selected) do
		local file = fzf_path.entry_to_file(entry, opts)
		if file.path and file.path ~= "" then
			M.open_file(file.path, tonumber(file.line), tonumber(file.col), index == #selected)
		end
	end
end

return M
