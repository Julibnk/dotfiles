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

-- load Lsp configs
local lsp_configs =
	{ "bashls", "composels", "cssls", "dockerls", "lua_ls", "prisma-language-server", "tailwindls", "vstls" }

-- for _, f in pairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
-- 	local server_name = vim.fn.fnamemodify(f, ":t:r")
-- 	table.insert(lsp_configs, server_name)
-- end

vim.lsp.enable(lsp_configs)
