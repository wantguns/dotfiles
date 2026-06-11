local select = require('nvim-treesitter-textobjects.select')
local move   = require('nvim-treesitter-textobjects.move')
local repeatable = require('nvim-treesitter-textobjects.repeatable_move')

require('nvim-treesitter-textobjects').setup({
  select = { lookahead = true },
  move   = { set_jumps = true },
})

local function map_select(key, capture)
  for _, mode in ipairs({ 'x', 'o' }) do
    vim.keymap.set(mode, key, function()
      select.select_textobject('@' .. capture, 'textobjects')
    end, { desc = 'TS select ' .. capture })
  end
end

map_select('af', 'function.outer')
map_select('if', 'function.inner')
map_select('ac', 'class.outer')
map_select('ic', 'class.inner')
map_select('aa', 'parameter.outer')
map_select('ia', 'parameter.inner')

local function map_move(key, fn, capture)
  vim.keymap.set({ 'n', 'x', 'o' }, key, function()
    move[fn]('@' .. capture, 'textobjects')
  end, { desc = 'TS ' .. fn .. ' ' .. capture })
end

map_move(']f', 'goto_next_start', 'function.outer')
map_move('[f', 'goto_previous_start', 'function.outer')
map_move(']F', 'goto_next_end', 'function.outer')
map_move('[F', 'goto_previous_end', 'function.outer')
map_move(']c', 'goto_next_start', 'class.outer')
map_move('[c', 'goto_previous_start', 'class.outer')
map_move(']a', 'goto_next_start', 'parameter.inner')
map_move('[a', 'goto_previous_start', 'parameter.inner')

vim.keymap.set({ 'n', 'x', 'o' }, ';', repeatable.repeat_last_move_next)
vim.keymap.set({ 'n', 'x', 'o' }, ',', repeatable.repeat_last_move_previous)
vim.keymap.set({ 'n', 'x', 'o' }, 'f', repeatable.builtin_f_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'F', repeatable.builtin_F_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 't', repeatable.builtin_t_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'T', repeatable.builtin_T_expr, { expr = true })
