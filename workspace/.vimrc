syntax enable "Подсветка.

set showcmd "Your input in command mode shows down the screen
set number
" set ruler "Положение курсора пока не понял как работает.
set relativenumber
set tabstop=4 "length tab into space. Влияет как на уже существующие табуляции, так и на новые.
set shiftwidth=4 "Количество пробелов, добавляемых командами << и  >>.
set smarttab "Нажатие tab в начале строки (до первого непробельного символа) приведёт к добавлению отступа, ширина которого соответствует shiftwidth (независимо от tabstop and softtabstop). Нажатие на Backspace удалит отступ, а не только один символ, что очень полезно при включённой expandtab. Опция влияет только на отступы в начале строки, в остальных местах используются значения из tabstop and softtabstop.
set expandtab "В режиме вставки заменяет символ табуляции на соответствующее количество пробелов. Так же влияет на отступы, добавляемые командами >> and <<.
set smartindent "копирует отступы с текущей строки при добавлении новой, + выставляет умные отступы (после {, перед строкой }, удаляется перед # и т. д.)

" Делать отступы равными два пробела для файлов yaml
autocmd FileType yaml setlocal shiftwidth=2 softtabstop=2 expandtab

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
autocmd BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

" Prepare to install dictionary
" mkdir -p ~/.vim/spell/
" cd ~/.vim/spell
" wget http://ftp.vim.org/vim/runtime/spell/ru.utf-8.sug
" wget http://ftp.vim.org/vim/runtime/spell/ru.utf-8.spl

"On/off check orthography
setlocal spell spelllang=ru,en_gb

" Orthography red
highlight clear SpellBad
highlight SpellBad ctermfg=Red
" Orphograpy red

" about autocmd see here: https://jenyay.net/Programming/VimScript9
" There are common view is autocmd {event} {pattern} {cmd}
" Running python code if file is .py
autocmd BufRead,BufNewFile *.py nmap <F5> <Esc>:w<CR>: !clear; python3 %<CR>
" Running bash script if file is .sh
autocmd BufRead,BufNewFile *.sh nmap <F5> <Esc>:w<CR>: !clear; bash %<CR>
" Running yaml lint if file is .yaml
autocmd BufRead,BufNewFile *.yaml,*.yml nmap <F5> <Esc>:w<CR>: !clear; yamllint %<CR>

" New options
" Включение синтаксиса groovy in Jenkinsfile
autocmd BufNewFile,BufRead *[jJ]enkinsfile set syntax=groovy

" Древовидный вид netrw
let g:netrw_liststyle = 3
" Открывать в netrw файл в новом окне. Где 2 - номер окна.
let g:netrw_chgwin = 2
" Изменить ширину окна обозревателя
let g:netrw_winsize = 25

" Изменение цветовой схемы в зависимости от времени суток
let hour=system('date +%H')

if hour >= 16
    colorscheme evening
endif

if hour < 16
    colorscheme darkblue
endif

" autocmd VimEnter * if &diff | execute 'windo set wrap' | endif

" vimsecrets ru topics https://dzen.ru/suite/7223522a-33e7-49df-b7d8-5cbbb12af396
