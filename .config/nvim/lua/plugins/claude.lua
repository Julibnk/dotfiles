return {
	"coder/claudecode.nvim",
	enabled = false,
	dependencies = { "folke/snacks.nvim", "Julibnk/claude-tmux.nvim" },
	config = function()
		local claude_tmux = require("claude-tmux")
		local terminal_config = {}
		if claude_tmux.is_available() then
			terminal_config.provider = claude_tmux.setup({
				split_size = 50,
			})
		end
		require("claudecode").setup({ terminal = terminal_config })
	end,
}
