return {
	"christoomey/vim-tmux-navigator",
	event = { "VeryLazy" },
	-- Sin esto el plugin crea sus ctrl+h/j/k/l y pisa los de mappings.lua.
	init = function()
		vim.g.tmux_navigator_no_mappings = 1
	end,
	cmd = {
		"TmuxNavigateLeft",
		"TmuxNavigateDown",
		"TmuxNavigateUp",
		"TmuxNavigateRight",
		"TmuxNavigatePrevious",
	},
	-- Los ctrl+h/j/k/l los pone mappings.lua.
	keys = {
		{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
	},
}
