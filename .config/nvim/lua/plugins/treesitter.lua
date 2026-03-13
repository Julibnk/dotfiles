return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	lazy = false,
	branch = "main",
	opts = {
		-- A list ttof parser names, or "all" (the listed parsers MUST always be installed)
		tnsure_installed = {
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
		},

		-- Install parsers synchronously (only applied to `ensure_installed`)
		-- sync_install = false,

		-- Automatically install missing parsers when entering buffer
		-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
		auto_install = true,

		---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
		-- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

		highlight = {
			enable = true,
		},
	},
}
