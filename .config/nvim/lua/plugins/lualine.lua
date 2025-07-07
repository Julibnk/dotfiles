-- TODO: Force update lualine on harpoon events to avoid lag
local function harpoon_section()
	local ok, harpoon = pcall(require, "harpoon")
	if ok then
		local bufname_in_harpoon = string.gsub(vim.api.nvim_buf_get_name(0), vim.loop.cwd() .. "/", "")
		local its_me, index = harpoon:list():get_by_value(bufname_in_harpoon)

		-- { icon = " ", color = "warning" },
		if its_me ~= nil then
			return "󰐃 " .. index .. "/" .. harpoon:list():length() .. ""
		end

		if harpoon:list():length() == 0 then
			return ""
		end
		return harpoon:list():length()
	else
		return nil
	end
end

local function is_recording()
	local reg = vim.fn.reg_recording()
	if reg == "" then
		return ""
	end -- not recording
	return "macro " .. reg
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
			lualine_b = { "branch", "diagnostics" },
			lualine_c = {
				{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
				{ "filename", path = 4 },
				{ harpoon_section, color = { fg = "#ffa500" } },
				{ is_recording, color = { fg = "#ffa500" } },
			},
			lualine_x = {
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
	},
}
