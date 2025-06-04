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
return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", "bwpge/lualine-pretty-path", "ThePrimeagen/harpoon" },
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
			lualine_a = { "mode" },
			lualine_b = { "branch", "diagnostics" },
			lualine_c = {
				{ "pretty_path", directories = {
					max_depth = 4,
				} },
				{ harpoon_section, color = { fg = "#ffa500" } },
			},
			lualine_x = { "lsp_status", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = { "filename" },
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},
		tabline = {},
		winbar = {},
		inactive_winbar = {},
	},
}
