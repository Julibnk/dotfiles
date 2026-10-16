-- Loads plenary and this nvim config's lua dir so specs can run headless.
local config_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h:h")

vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/plenary.nvim")
vim.opt.rtp:append(config_dir)
vim.cmd("runtime plugin/plenary.vim")
