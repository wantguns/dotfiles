vim.lsp.config('zls', {
  cmd = { 'zls' },
  filetypes = { 'zig', 'zon' },
  root_markers = { 'build.zig', '.git' },
})
vim.lsp.enable('zls')
