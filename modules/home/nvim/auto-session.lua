-- auto-session warns unless sessionoptions keeps buffers and localoptions.
vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,terminal,winsize,winpos,localoptions"

require('auto-session').setup({
  suppressed_dirs = { '~/', '~/Downloads', '/' },
  close_filetypes_on_save = {
    'checkhealth',
    'fugitive',
    'fugitiveblame',
    'git',
    'gitcommit',
    'gitrebase',
    'oil',
  },
})
