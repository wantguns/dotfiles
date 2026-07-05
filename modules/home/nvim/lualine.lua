local Path = require('plenary.path')

local function rel_path()
  local full = vim.fn.expand('%:p')
  if full == '' then return '[No Name]' end
  local root = vim.fn.FugitiveWorkTree()
  return Path:new(full):make_relative(root ~= '' and root or vim.fn.getcwd())
end

local function oil_dir()
  return vim.fn.fnamemodify(require('oil').get_current_dir() or '', ':~')
end

require('lualine').setup{
  options = {
    icons_enabled = false,
    component_separators = '|',
    section_separators = '',
  },
  sections = {
    lualine_c = {
      { oil_dir, cond = function() return vim.bo.filetype == 'oil' end },
      { rel_path, cond = function() return vim.bo.filetype ~= 'oil' end },
    },
  },
}
