return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()
		local map = vim.keymap.set
		map("n", "<leader>H", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end)
		map("n", "<leader>h", function()
			harpoon:list():add()
		end)
		map("n", "<leader>ha", function()
			harpoon:list():select(1)
		end)
		map("n", "<leader>hs", function()
			harpoon:list():select(2)
		end)
		map("n", "<leader>hd", function()
			harpoon:list():select(3)
		end)
		map("n", "<leader>hf", function()
			harpoon:list():select(4)
		end)
		map("n", "<leader>hg", function()
			harpoon:list():select(5)
		end)
	end,
	opts = {},
}
