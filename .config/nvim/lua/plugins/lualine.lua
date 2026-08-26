local function harpoon_section()
	local ok, harpoon = pcall(require, "harpoon")
	if ok then
		local bufname_in_harpoon = string.gsub(vim.api.nvim_buf_get_name(0), vim.pesc(vim.loop.cwd() .. "/"), "")
		local its_me = harpoon:list():get_by_value(bufname_in_harpoon)
		local len = #harpoon:list().items

		-- { icon = " ", color = "warning" },
		if its_me ~= nil then
			return len .. " 󰐃"
		end

		return len
	end
	return ""
end

local function git_file_status()
	local ok, cache = pcall(require, "gitsigns.cache")
	if not ok then
		return ""
	end

	local bcache = cache.cache[vim.api.nvim_get_current_buf()]
	-- Sin cache = el buffer no está en un repo git (o gitsigns aún no ha attachado).
	if not bcache then
		return ""
	end

	-- gitsigns deja object_name a nil cuando el fichero no está en el index.
	if bcache.git_obj.object_name == nil then
		return "?"
	end

	local d = vim.b.gitsigns_status_dict
	if d and ((d.added or 0) + (d.changed or 0) + (d.removed or 0)) > 0 then
		return "M"
	end

	return ""
end

-- Mismos códigos y colores que el picker `git_status` de fzf-lua
-- (defaults.lua: M = yellow, ? = magenta). fzf pinta con los colores ansi
-- del terminal, así que usamos los de nvim si el colorscheme los define
-- (catppuccin trae `term_colors = false`) y si no, los de la config de kitty.
local git_status_color = {
	["M"] = { 3, "#f9e2af" }, -- yellow
	["?"] = { 5, "#f5c2e7" }, -- magenta
}

local function git_file_status_color()
	local c = git_status_color[git_file_status()]
	if c then
		return { fg = vim.g["terminal_color_" .. c[1]] or c[2] }
	end
end

local function gitsigns_diff_source()
	-- Reusa el recuento de gitsigns en vez de que lualine lance su propio
	-- `git diff --numstat` en background.
	local d = vim.b.gitsigns_status_dict
	if d then
		return { added = d.added, modified = d.changed, removed = d.removed }
	end
end

local function is_recording()
	local reg = vim.fn.reg_recording()
	if reg == "" then
		return ""
	end -- not recording
	return "macro " .. reg
end

local function is_dap_session_active()
	local dap = require("dap")
	if #dap.sessions() > 1 then
		return "[  " .. #dap.sessions() .. "]"
	end
	if dap.session() ~= nil then
		return "[  " .. dap.session().config.name .. "]"
	end
	return ""
end

local function mode_fmt(mode)
	local width = vim.fn.winwidth(0)
	if width <= 88 then
		return string.sub(mode, 1, 1)
	end
	return mode
end

local function responsive_disable(content)
	local width = vim.fn.winwidth(0)
	if width <= 88 then
		return ""
	end
	return content
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", "ThePrimeagen/harpoon" },
	opts = {
		options = {
			icons_enabled = true,
			theme = "auto",
			component_separators = { left = "", right = "" },
			section_separators = { left = "", right = "" },
			disabled_filetypes = {
				statusline = {},
				winbar = {},
			},
			ignore_focus = {},
			always_divide_middle = true,
			always_show_tabline = true,
			globalstatus = false,
			refresh = {
				statusline = 100,
				tabline = 100,
				winbar = 100,
			},
		},
		sections = {
			lualine_a = { { "mode", fmt = mode_fmt } },
			-- lualine_b = { "branch", "diagnostics" },
			lualine_b = { "diagnostics" },
			lualine_c = {
				{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
				{ "filename", path = 1 },
				{ git_file_status, color = git_file_status_color },
				{ "diff", source = gitsigns_diff_source },
				{ harpoon_section, color = { fg = "#f2f1ef" } },
				{ is_recording, color = { fg = "#f2f1ef" } },
			},
			lualine_x = {
				{ is_dap_session_active, color = "DiagnosticError" },
				{ "lsp_status", ignore_lsp = { "tailwindls" }, fmt = responsive_disable },
				{ "filetype", fmt = responsive_disable },
			},
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = { "filename" },
			lualine_x = { "location", "fileformat" },
			lualine_y = {},
			lualine_z = {},
		},
		tabline = {},
		winbar = {},
		inactive_winbar = {},
		extensions = { "quickfix", "oil" },
	},
}
