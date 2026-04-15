require("config.lazy")
require("opts")
require("mappings")
require("lsp")
require("vim._core.ui2").enable()

vim.cmd("packadd nvim.undotree")

-- Autocomands
-- Highlight when yanking text
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	desc = "Highlight yanked text",
	group = vim.api.nvim_create_augroup("highlight", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_user_command("CmdLog", function(opts)
	local output = vim.fn.execute(opts.args)
	vim.cmd("new")
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n"))
	vim.bo.buftype = "nofile"
end, { nargs = "+", complete = "command" })

vim.api.nvim_create_user_command("TscQuickfix", function()
	local tmpfile = vim.fn.tempname()
	local cmd = "tsc --noEmit > " .. tmpfile .. " 2>&1"
	print("Running tsc...")
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

--DAP  Stop sign
vim.api.nvim_set_hl(0, "debugSignPC", { fg = "#43242b" })

vim.fn.sign_define("DapBreakpointCondition", { text = " ", texthl = "SignColumn", linehl = "@comment.warning" })
vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "DapUIWatchesError", linehl = "@comment.error" })
vim.fn.sign_define("DapStopped", { text = " ", texthl = "debugSignPC", linehl = "debugPC" })
vim.fn.sign_define("DapLogPoint", { text = " ", texthl = "SignColumn" })
vim.fn.sign_define("DapBreakpointRejected", { text = " ", texthl = "SignColumn" })
