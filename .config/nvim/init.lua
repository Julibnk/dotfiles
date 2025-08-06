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

vim.api.nvim_create_user_command("TscQuickfix", function()
	local tmpfile = vim.fn.tempname()
	local cmd = "tsc --noEmit > " .. tmpfile .. " 2>&1"
	os.execute(cmd)

	local lines = vim.fn.readfile(tmpfile)
	local efm = "%f(%l\\,%c): %t%m"

	local qfitems = vim.fn.getqflist({ lines = lines, efm = efm }).items

	vim.fn.setqflist(qfitems, "r")

	vim.cmd("copen")
end, {})

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
