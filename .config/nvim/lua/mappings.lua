-- Keymaps
vim.keymap.set("i", "jk", "<Esc>")

vim.keymap.set("n", "<left>", '<cmd>echo "Don`t do that"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Don`t do that"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Don`t do that"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Don`t do that"<CR>')

--Move between windows
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lowwe window" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })

--Buffers
vim.keymap.set("n", "<leader>bd", "<cmd>bd!<CR>", { desc = "[B]uffer [b]elete" })
vim.keymap.set("n", "<leader>bw", "<cmd>w<CR>", { desc = "[B]uffer [w]rite" })
-- vim.keymap.set("n", "<leader>br", "<cmd>e<CR>", { desc = "[B]uffer [r]eload" })

--Paste
vim.keymap.set("n", "<leader>p", '"0p', { desc = "[p]ut 0 register" })
vim.keymap.set("n", "<leader>P", '"0P', { desc = "[P]ut 0 register" })
--Diagnostics
-- vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic" })

--Quickfix list
vim.keymap.set("n", "<C-n>", "<cmd>cne<CR>", { desc = "Move next quickfix list item" })
vim.keymap.set("n", "<C-p>", "<cmd>cp<CR>", { desc = "Move focus to the lowwe window" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up centered" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result centerd" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search result centerd" })

-- Delete default mapings for go to reference
vim.keymap.del("n", "grr")
vim.keymap.del({ "n", "x" }, "gra")
vim.keymap.del("n", "grn")
vim.keymap.del("n", "gri")
