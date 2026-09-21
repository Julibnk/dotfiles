-- Mitad editor de vim-herdr-navigation: ctrl+h/j/k/l entre splits de nvim y paneles de herdr.
-- El repo no es un plugin de nvim normal (no hay lua/), por eso el dofile.
-- dependencies fija el orden de carga: si no, vim-tmux-navigator pisa estos mapeos.
return {
	"paulbkim-dev/vim-herdr-navigation",
	dependencies = { "christoomey/vim-tmux-navigator" },
	event = "VeryLazy",
	config = function(plugin)
		dofile(plugin.dir .. "/editor/nvim.lua")
	end,
}
