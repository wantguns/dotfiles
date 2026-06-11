require('telescope').setup({
  defaults = {
    layout_strategy = 'bottom_pane',
    layout_config = {
      bottom_pane = {
        height = 20,
        prompt_position = 'bottom',
      },
    },
    border = true,
    sorting_strategy = 'ascending',
  },
})

local b = require('telescope.builtin')
vim.keymap.set('n', '<leader>s?', b.oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader>sf', b.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', b.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', b.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', b.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>so', b.lsp_document_symbols, { desc = '[D]ocument [S]ymbols' })
vim.keymap.set('n', '<leader>ss', b.lsp_dynamic_workspace_symbols, { desc = '[W]orkspace [S]ymbols' })
vim.keymap.set('n', '<leader>sd', b.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', b.lsp_references, { desc = '[G]oto [R]eferences' })
vim.keymap.set('n', '<leader>sb', b.buffers, { desc = '[S]earch [B]uffers' })
vim.keymap.set('n', '<leader>so', b.oldfiles, { desc = '[S]earch [O]ldfiles' })
vim.keymap.set('n', '<leader>si', b.lsp_implementations, { desc = '[S]earch [I]mplementation' })
vim.keymap.set('n', '<leader>st', b.git_files, { desc = '[S]earch Gi[T]/[T]racker files' })
