vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml',
                   'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
})
vim.lsp.enable('lua_ls')
