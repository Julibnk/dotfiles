-- lazy.nvim
return {
	"folke/snacks.nvim",
	---
	---@module 'snacks'
	---@type snacks.Config
	opts = {
		scratch = {
			-- your scratch configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
	keys = {
		{
			"<leader>.",
			function()
				local name = vim.fn.input({})
				local win = Snacks.scratch.open()
			end,
			desc = "Toggle Scratch Buffer",
		},
		{
			"<leader>S",
			function()
				Snacks.scratch.select()
			end,
			desc = "Select Scratch Buffer",
		},
	},
}
