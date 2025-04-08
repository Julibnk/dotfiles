return {
	'stevearc/oil.nvim',
	keys = {
		{ '-' , '<cmd>Oil<cr>', desc = 'Open Oil' }, 
	},
	opts = {
		keymaps = {
			["h"] = {"actions.parent" },
			["-"] = {"actions.close" },
			["l"] = {"actions.select" },
		}
	
}
}
