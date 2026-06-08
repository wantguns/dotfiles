require('nvim-treesitter').setup({})

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    local ok, _ = pcall(vim.treesitter.start)
    if ok then
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo.foldenable = false 
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

local parser_config = require('nvim-treesitter.parsers')

parser_config.gotmpl = {
  install_info = {
    url = "https://github.com/ngalaiko/tree-sitter-go-template",
    files = {"src/parser.c"}
  },
  filetype = "gotmpl",
}

vim.treesitter.language.register('gotmpl', { 'gohtmltmpl', 'gotexttmpl', 'gotmpl', 'tpl' })
