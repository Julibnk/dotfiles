return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		local Path = require("plenary.path")
		harpoon:setup({
			settings = {
				save_on_toggle = true,
				save_on_change = true,
			},
		})
		local map = vim.keymap.set
		map("n", "<leader>hh", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end)
		map("n", "<leader>M", function()
			local function normalize_path(buf_name, root)
				return Path:new(buf_name):make_relative(root)
			end
			local bufname = normalize_path(vim.api.nvim_buf_get_name(0), harpoon:list().config.get_root_dir())
			local item = harpoon:list():get_by_value(bufname)
			if item ~= nil then
				harpoon:list():remove(item)
			end
		end)
		map("n", "<leader>m", function()
			harpoon:list():add()
		end)
		map("n", "<leader>1", function()
			harpoon:list():select(1)
		end)
		map("n", "<leader>2", function()
			harpoon:list():select(2)
		end)
		map("n", "<leader>3", function()
			harpoon:list():select(3)
		end)
		map("n", "<leader>4", function()
			harpoon:list():select(4)
		end)
		map("n", "<leader>5", function()
			harpoon:list():select(5)
		end)
	end,
	opts = {},
}
