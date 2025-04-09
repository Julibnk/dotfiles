-- Options
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.hlsearch = true 
vim.opt.incsearch = true 

vim.opt.wrap = false

vim.opt.smartindent = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.undofile = true

vim.opt.scrolloff = 8

vim.opt.swapfile = false
vim.opt.backup = false

vim.schedule(function()
    vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.signcolumn = 'yes'
vim.opt.colorcolumn = '80'

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldtext = ''
vim.opt.foldlevel = 99

