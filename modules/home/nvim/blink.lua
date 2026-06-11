require('blink.cmp').setup({
  completion = {
    menu = {
      draw = {
        columns = {
          { 'label', 'label_description', gap = 1 },
          { 'kind' },
        },
      },
    },
    documentation = {
      auto_show = true,
    },
    list = { selection = { auto_insert = false } },
  },

  signature = {
    enabled = true,
  },

  keymap = {
    preset = 'default',
    ['<CR>']    = { 'accept', 'fallback' },
    ['<Tab>']   = { 'snippet_forward', 'select_next', 'fallback' },
    ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },
  },

  appearance = {
    use_nvim_cmp_as_default = true,
  },
})
