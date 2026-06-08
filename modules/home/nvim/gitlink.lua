require('gitlinker').setup()
vim.keymap.set({'n', 'v'}, '<leader>gy', "<cmd>GitLink<cr>", { desc = 'Yank git link' })
vim.keymap.set({'n', 'v'}, '<leader>gY', "<cmd>GitLink!<cr>", { desc = 'Open git link' })
