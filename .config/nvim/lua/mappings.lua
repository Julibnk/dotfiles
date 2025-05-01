-- Keymaps
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "jj", "<Esc>")

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

--Diagnostics
-- vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic" })
