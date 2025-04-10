return {
	'rebelot/kanagawa.nvim',
	lazy = false,
	priority = 1000,
	config = function() 
		vim.cmd('colorscheme kanagawa')
		vim.api.nvim_create_user_command('GNight', function() vim.cmd([[colorscheme kanagawa]]) end, {})
		vim.api.nvim_create_user_command('GMorning', function() vim.cmd([[colorscheme kanagawa-lotus]]) end, {})
	end,
} 
