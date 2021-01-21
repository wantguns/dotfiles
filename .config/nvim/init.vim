" ABOUT: VIMRC
" AUTHOR: WantGuns <mail@wantguns.dev>

"*****************************************************************************
"" Vim-PLug core
"*****************************************************************************
let vimplug_exists=expand('~/.config/nvim/autoload/plug.vim')

if !filereadable(vimplug_exists)
  if !executable("curl")
    echoerr "You have to install curl or first install vim-plug yourself!"
    execute "q!"
  endif
  echo "Installing Vim-Plug..."
  echo ""
  silent exec "!\curl -fLo " . vimplug_exists . " --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  let g:not_finish_vimplug = "yes"

  autocmd VimEnter * PlugInstall
endif

" Required:
call plug#begin(expand('~/.config/nvim/plugged'))

"*****************************************************************************
"" Plug install packages
"*****************************************************************************
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'mhinz/vim-startify'
Plug 'preservim/nerdtree'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'honza/vim-snippets'
Plug 'itchyny/lightline.vim'
Plug 'psliwka/vim-smoothie'
Plug 'Raimondi/delimitMate'
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/goyo.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'ayu-theme/ayu-vim'
Plug 'tpope/vim-sensible'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
Plug 'vimwiki/vimwiki'


call plug#end()

"*****************************************************************************
"" Basic Setup
"*****************************************************************************"
"" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8

" Relative Numbers gutter
set relativenumber

"" Enable mouse-mode (pls no judge)
set mouse=a

"" Fix backspace indent
set backspace=indent,eol,start

"" Tabs. May be overridden by autocmd rules
set tabstop=4
set softtabstop=0
set shiftwidth=4
set expandtab

"" Map leader to ,
let mapleader=','

"" Enable hidden buffers
set hidden

"" Searching
set incsearch
set ignorecase
set smartcase

"" C-Backspace deletes last word
inoremap <C-H> <C-W>

"" Tab navigation
nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt
nnoremap <leader>6 6gt
nnoremap <leader>7 7gt
nnoremap <leader>8 8gt
nnoremap <leader>9 9gt

"" Tab commands
nnoremap th  :tabfirst<CR>
nnoremap tk  :tabnext<CR>
nnoremap tj  :tabprev<CR>
nnoremap tl  :tablast<CR>
nnoremap te  :tabedit<Space>
nnoremap tn  :tabnext<Space>
nnoremap tm  :tabm<Space>
nnoremap td  :tabclose<CR>

"" Last Tab switch
" Switch to last-active tab
if !exists('g:Lasttab')
    let g:Lasttab = 1
    let g:Lasttab_backup = 1
endif
autocmd! TabLeave * let g:Lasttab_backup = g:Lasttab | let g:Lasttab = tabpagenr()
autocmd! TabClosed * let g:Lasttab = g:Lasttab_backup
nnoremap tt :exe "tabn " . g:Lasttab<cr>

"*****************************************************************************
"" Visual Settings
"*****************************************************************************
syntax on
set ruler
set number

let no_buffers_menu=1

" True Colors for tmux
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors
let ayucolor="dark"
silent! colorscheme ayu

" lightline theme
let g:lightline = { 
\  'colorscheme' : 'ayu_dark',
\  'active': {
\    'right': [[ 'lineinfo' ]],
\    'left': [[ 'mode', 'paste' ],
\             [ 'readonly', 'relativepath', 'gitbranch', 'modified', 'cocstatus' ]]
\  },
\  'component_function': {
\    'gitbranch': 'fugitive#head',
\    'cocstatus': 'coc#status',
\  },
\  'component_type': {
\    'cocstatus': 'warning',
\  }, 
\ }

"" Vmap for maintain Visual Mode after shifting > and <
vmap < <gv
vmap > >gv

"" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

"" Copy/Paste/Cut
set clipboard=unnamed,unnamedplus

"" Transparent background
hi Normal guibg=NONE ctermbg=NONE

"*****************************************************************************
"" Abbreviations
"*****************************************************************************
"" no one is really happy until you have this shortcuts
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Wq wq
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q

"*****************************************************************************
"" Autocmd Rules
"*****************************************************************************
"" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

"*****************************************************************************
"" Plugin-Centric
"*****************************************************************************

"" Split
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>

"" Git
noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gc :Gcommit<CR>
noremap <Leader>gsh :Gpush<CR>
noremap <Leader>gll :Gpull<CR>
noremap <Leader>gs :Gstatus<CR>
noremap <Leader>gb :Gblame<CR>
noremap <Leader>gd :Gvdiff<CR>
noremap <Leader>gr :Gremove<CR>


"" fzf.vim
set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git,*.rbc,*.pyc,__pycache__
let $FZF_DEFAULT_COMMAND =  "find * -path '*/\.*' -prune -o -path 'node_modules/**' -prune -o -path 'target/**' -prune -o -path 'dist/**' -prune -o  -type f -print -o -type l -print 2> /dev/null"

" ripgrep
if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
  set grepprg=rg\ --vimgrep
  command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>).'| tr -d "\017"', 1, <bang>0)
endif

nnoremap <silent> <leader>f :FZF -m<CR>
nnoremap <silent> <Leader>/ :Find<CR>

"" NERDTree (but with tabs now)
map <Leader>n <plug>NERDTreeTabsToggle<CR>

"" Goyo
map <silent> <C-f> :Goyo<CR>

"" COC
let g:coc_global_extensions = ['coc-rust-analyzer', 'coc-python', 'coc-clangd']

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

inoremap <silent><expr> <c-space> coc#refresh()

"" Snippets
" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)
" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)
" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-j>'
" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-k>'
" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)

" GoTo code navigation.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

nmap <silent> gd :call CocAction('jumpDefinition', 'vsplit')<cr>
nmap <silent> gD <Plug>(coc-definition)

nmap <silent> gy :call CocAction('jumpTypeDefinition', 'vsplit')<cr>
nmap <silent> gY <Plug>(coc-type-definition)

nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nmap <leader>qf  <Plug>(coc-fix-current)


"" VimWiki

let wiki = {}
let wiki.nested_syntaxes = {'py': 'python', 'c++': 'cpp', 'rust': 'rust', 'c': 'c'}
let g:vimwiki_list = [wiki]

""

"*****************************************************************************
"" Miscellaneous
"*****************************************************************************

"" Competitive Programming max
nnoremap <leader>cp :-1read $HOME/.config/nvim/templates/compprog.cpp<CR>13ji<Tab>
autocmd filetype cpp nnoremap <leader>r :!clang++ -std=c++17 % -o %:r<CR>:!./%:r<CR>
nnoremap <leader>p :!curl -X POST --data-binary @% https://bin.wantguns.dev<CR>
