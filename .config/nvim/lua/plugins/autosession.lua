return {

	"rmagatti/auto-session",
	lazy = false,

	---enables autocomplete for opts
	---@module "auto-session"
	---@type AutoSession.Config
	opts = {
		suppressed_dirs = { "~/", "~/Documents", "~/Downloads", "/" },
		-- Keeps Neo-tree out of saved sessions, which would otherwise restore it as an empty window.
		pre_save_cmds = { "Neotree close" },
		-- log_level = 'debug',
	},
}
