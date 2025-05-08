require("config.lazy")
require("opts")
require("mappings")

-- Autocomands
-- Highlight when yanking text
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	desc = "Highlight yanked text",
	group = vim.api.nvim_create_augroup("highlight", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.HINT] = "",
			[vim.diagnostic.severity.INFO] = "",
		},
	},
	severity_sort = true,
	float = {
		border = "single",
	},
})
