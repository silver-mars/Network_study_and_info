syntax enable "Подсветка.

set showcmd "Input в командном режиме отображается снизу-справа
set number
set relativenumber "навигация по относительным строкам
set tabstop=4 "length tab into space. Влияет как на уже существующие табуляции, так и на новые.
set shiftwidth=4 "Количество пробелов, добавляемых командами << и  >>.
set smarttab "Нажатие tab в начале строки (до первого непробельного символа) приведёт к добавлению отступа, ширина которого соответствует shiftwidth (независимо от tabstop and softtabstop). Нажатие на Backspace удалит отступ, а не только один символ, что очень полезно при включённой expandtab. Опция влияет только на отступы в начале строки, в остальных местах используются значения из tabstop and softtabstop.
set expandtab "В режиме вставки заменяет символ табуляции на соответствующее количество пробелов. Так же влияет на отступы, добавляемые командами >> and <<.
set smartindent "копирует отступы с текущей строки при добавлении новой, + выставляет умные отступы (после {, перед строкой }, удаляется перед # и т. д.)

colorscheme default
set foldmethod=syntax "Сворачивать код по синтаксису языка.
set nofoldenable "При открытии документов не сворачивать код автоматически.

set incsearch "Быстро показывать первое вхождение шаблона при поиске.

set wildmenu "Достраивать в меню перебор файлов для редактирования.
set cursorline "Подсветка текущей строки.

set keymap=russian-jcukenwin
set iminsert=0 " Чтобы при старте ввод был на английском, а не русском (start > i)
set imsearch=0 " Чтобы при старте поиск был на английском, а не русском (start > /)
" highlight 1Cursor guifg=NONE guibg=Cyan

set foldmethod=indent
" setlocal spell spelllang=ru_yo,en_us На будущее про переносы строк.

" Use the below highlight group when displaying bad whitespace is desired.
highlight BadWhitespace ctermbg=red guibg=red
" Make trailing whitespace be flagged as bad.
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

"Prepare to install dictionary
"mkdir -p ~/.vim/spell/
"cd ~/.vim/spell
"wget http://ftp.vim.org/vim/runtime/spell/ru.utf-8.sug
"wget http://ftp.vim.org/vim/runtime/spell/ru.utf-8.spl
setlocal spell spelllang=ru,en_gb
"On/off check spelling

highlight clear SpellBad
highlight SpellBad ctermfg=Red
" Spelling red

" Running python code
nmap <F5> <Esc>:w<CR>: !clear; python3 %<CR>
