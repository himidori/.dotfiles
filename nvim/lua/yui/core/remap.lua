local keymap = vim.keymap

keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- general

keymap.set("n", "<leader>nh", ":nohl<CR>")

keymap.set("n", "x", '"_x')

keymap.set("n", "<leader>+", "<C-a>")
keymap.set("n", "<leader>-", "<C-x>")

-- splitting
-- keymap.set("n", "<leader>sv", "<C-w>v")
-- keymap.set("n", "<leader>sh", "<C-w>s")
-- keymap.set("n", "<leader>se", "<C-w>=")
-- keymap.set("n", "<leader>sx", ":close<CR>")
-- keymap.set("n", "<leader>sf", ":MaximizerToggle<CR>")
keymap.set("n", "<C-x>3", "<C-w>v")
keymap.set("n", "<C-x>2", "<C-w>s")
keymap.set("n", "<C-x>=", "<C-w>=")
keymap.set("n", "<C-x>k", ":close<CR>")
keymap.set("n", "<C-x>f", ":MaximizerToggle<CR>")
keymap.set("n", "<C-x>o", "<C-w>o")
