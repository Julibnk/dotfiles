-- Mitad editor de vim-herdr-navigation: ctrl+h/j/k/l entre splits de nvim y paneles de herdr.
-- El repo no es un plugin de nvim normal (no hay lua/), por eso el dofile.
-- dependencies fija el orden de carga: si no, vim-tmux-navigator pisa estos mapeos.

-- El sidebar de herdr-nvim corre en un daemon headless cuyo HERDR_PANE_ID falta o es viejo.
-- Por eso, en el borde de un split, se mueve desde el panel enfocado, que es donde se pulsó la tecla.
-- TODO: quitar cuando herdr-nvim pase el panel real del sidebar a su daemon.
local function map_sidebar_edges()
	vim.env.HERDR_PANE_ID = nil
	local herdr = vim.env.HERDR_BIN_PATH or "herdr"
	for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
		vim.keymap.set("n", "<C-" .. key .. ">", function()
			local prev = vim.api.nvim_get_current_win()
			vim.cmd("wincmd " .. key)
			if vim.api.nvim_get_current_win() == prev then
				vim.fn.system({ herdr, "pane", "focus", "--direction", dir, "--current" })
			end
		end, { silent = true, desc = "Navigate " .. dir .. " (herdr-nvim sidebar)" })
	end
end

return {
	"paulbkim-dev/vim-herdr-navigation",
	dependencies = { "christoomey/vim-tmux-navigator" },
	event = "VeryLazy",
	config = function(plugin)
		dofile(plugin.dir .. "/editor/nvim.lua")
		if vim.env.HERDR_PLUGIN_ID == "chmarax.herdr-nvim" then
			map_sidebar_edges()
		end
	end,
}
