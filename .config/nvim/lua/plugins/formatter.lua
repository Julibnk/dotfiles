return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>F",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	opts = {

		formatters_by_ft = {
			css = { "prettierd", "prettier" },
			-- graphql = { 'prettierd', 'prettier' },
			html = { "prettierd", "prettier" },
			javascript = { "prettierd", "prettier" },
			javascriptreact = { "prettierd", "prettier" },
			json = { "prettierd", "prettier" },
			lua = { "stylua" },
			markdown = { "prettierd", "prettier" },
			python = { "isort", "black" },
			-- sql = { 'sql-formatter' },
			typescript = { "prettierd", "prettier", "sql-formatter" },
			typescriptreact = { "prettierd", "prettier" },
			yaml = { "prettier" },
			-- liquid = { 'prettier' },
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
	},
}
