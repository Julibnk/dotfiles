local ft = {
	"bash",
	"html",
	"json",
	"json5",
	"lua",
	"luadoc",
	"query",
	"go",
	"markdown",
	"markdown_inline",
	"prisma",
	"javascript",
	"typescript",
	"tsx",
	"vim",
	"sql",
	"vimdoc",
	"xml",
}
vim.api.nvim_create_autocmd("FileType", {
	pattern = ft,
	callback = function()
		vim.treesitter.start()
	end,
})
return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	-- main = "nvim-treesitter.configs", -- Sets main module to use for opts
	branch = "main",
	config = function()
		local treesitter = require("nvim-treesitter")
		treesitter.install(ft)
	end,
}
