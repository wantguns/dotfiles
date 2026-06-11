-- Default capabilities applied to every LSP server.
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(
    vim.lsp.protocol.make_client_capabilities()
  ),
})

-- One global LspAttach autocmd handles keymaps for any attached server.
-- See :h lsp-attach.
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local nmap = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
    nmap('[d', vim.diagnostic.goto_prev, 'Previous diagnostic')
    nmap(']d', vim.diagnostic.goto_next, 'Next diagnostic')
    nmap('ge', vim.diagnostic.open_float, 'Floating diagnostic')
    nmap('gq', vim.diagnostic.setloclist, 'Diagnostics list')
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, '[W]orkspace [L]ist Folders')

    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function() vim.lsp.buf.format() end,
      { desc = 'Format current buffer with LSP' })
  end,
})
