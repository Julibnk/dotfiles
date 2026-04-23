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

	pattern = vim.tbl_deep_extend("force", ft, { "cs" }),
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
		local parsers = vim.tbl_deep_extend("force", ft, { "c_sharp" })
		local treesitter = require("nvim-treesitter")
		treesitter.install(parsers)
	end,
}
