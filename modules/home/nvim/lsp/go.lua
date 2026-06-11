vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
})
vim.lsp.enable('gopls')

vim.lsp.config('golangci_lint_ls', {
  cmd = { 'golangci-lint-langserver' },
  filetypes = { 'go', 'gomod' },
  root_markers = { 'go.work', 'go.mod', '.git' },
  init_options = {
    command = { 'golangci-lint', 'run', '--output.json.path=stdout',
                '--output.text.path=/dev/null', '--show-stats=false' },
  },
})
vim.lsp.enable('golangci_lint_ls')
