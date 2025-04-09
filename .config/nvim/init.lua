require('config.lazy')
require('opts')
require('mappings')

-- Autocomands
-- Highlight when yanking text
vim.api.nvim_create_autocmd({'TextYankPost'}, {
	desc = 'Highlight yanked text',
	group = vim.api.nvim_create_augroup('highlight', {clear = true}),
	callback = function() vim.highlight.on_yank() end,
})

-- vim.api.nvim_create_user_command('Night', function() 
-- 	vim.colorscheme = 'kanawaga'
-- 	end, {})

-- vim.colorscheme("kanawaga.dragon")
