-- Claude corre en su propia terminal; nvim solo expone el servidor /ide
-- (contexto de fichero y selección, diffs propuestos y diagnósticos del LSP).
return {
	"coder/claudecode.nvim",
	-- Apagado: Orca lleva los agentes y sus diffs, así que nvim no expone el servidor /ide.
	enabled = false,
	-- Se carga al arrancar para que el servidor esté listo cuando Claude lo busque.
	event = "VeryLazy",
	opts = {
		terminal = { provider = "none" },
	},
	keys = {
		{ "<leader>a", nil, desc = "AI/Claude Code" },
		{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
		{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
		{
			"<leader>as",
			"<cmd>ClaudeCodeTreeAdd<cr>",
			desc = "Add file",
			ft = { "neo-tree", "oil" },
		},
		{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
		{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
		{ "<leader>ai", "<cmd>ClaudeCodeStatus<cr>", desc = "Claude connection status" },
	},
}
