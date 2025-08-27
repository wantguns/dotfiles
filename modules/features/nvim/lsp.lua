local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Diagnostics
  nmap('[d', vim.diagnostic.goto_prev, 'Go to previous diagnostic message')
  nmap(']d', vim.diagnostic.goto_next,  'Go to next diagnostic message')
  nmap('ge', vim.diagnostic.open_float, 'Open floating diagnostic message')
  nmap('gq', vim.diagnostic.setloclist, 'Open diagnostics list')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
require('lspconfig').gopls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
}
require('lspconfig').golangci_lint_ls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    init_options = {
      command = { "golangci-lint", "run", "--output.json.path=stdout", "--output.text.path=/dev/null", "--show-stats=false" },
    },
}
require('lspconfig').pyright.setup {
    capabilities = capabilities,
    on_attach = on_attach,
}
require('lspconfig').terraformls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
}
require('lspconfig').ts_ls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
}
require('lspconfig').lua_ls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
}
