require('config.lazy')


-- Options
vim.opt.number = true
vim.opt.relativenumber = true
-- Keymaps
vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('i', 'jj', '<Esc>')

vim.keymap.set('n', '<left>', '<cmd>echo "Don`t do that"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Don`t do that"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Don`t do that"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Don`t do that"<CR>')

--Move between windows
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lowwe window' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })


--Buffers
-- vim.keymap.set('n', '<leader>bn', ':bn<CR>', { desc = '[B]uffer [n]ext' })
-- vim.keymap.set('n', '<leader>bp', ':bp<CR>', { desc = '[B]uffer [p]revious' })
vim.keymap.set('n', '<leader>bd', ':bd<CR>', { desc = '[B]uffer [b]elete' })
vim.keymap.set('n', '<leader>bw', ':w<CR>', { desc = '[B]uffer [w]rite' })

-- Autocomands
-- Highlight when yanking text
vim.api.nvim_create_autocmd({'TextYankPost'}, {
	desc = 'Highlight yanked text',
	group = vim.api.nvim_create_augroup('highlight', {clear = true}),
	callback = function() vim.highlight.on_yank() end,
})
vim.cmd("colorscheme kanawaga")

-- vim.api.nvim_create_user_command('Night', function() 
-- 	vim.colorscheme = 'kanawaga'
-- 	end, {})

-- vim.colorscheme("kanawaga.dragon")
