-- El plugin se queda: herdr-nav.lua usa sus comandos :TmuxNavigate* como
-- fallback cuando estas en tmux pero no en herdr.
return {
	"christoomey/vim-tmux-navigator",
	event = { "VeryLazy" },
	-- Sin esto el plugin crea sus ctrl+h/j/k/l y pisa los de herdr-nav.
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
	-- Los ctrl+h/j/k/l los pone ahora herdr-nav.lua.
	keys = {
		{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
	},
}
