#!/bin/bash

# объявление ассоциативного списка
declare -A colour
colour[black]='\033[30m'
colour[red]='\033[31m'
colour[green]='\033[32m'
colour[orange]='\033[33m'
colour[blue]='\033[34m'
colour[magenta]='\033[35m'
colour[cyan]='\033[36m'
colour[white]='\033[37m'
colour[clean]='\033[0m'

# @ - указание всех элементов
for key in "${!colour[@]}"; do
    echo -e "${colour[$key]}This is ""$key"" text ${colour[clean]}"
done

function demo_256_colour {
    if [ "$TERM" == 'xterm-256color' ]
    then
        for((i=16; i<256; i++)); do
            # 38 - foreground
            # 48 - background
            printf "\033[38;5;${i}m%03d" $i;
            printf '\033[0m'; # clean colour
            # Если это не 6-ой элемент печатаем printf ' '
            # Если шестой - печатаем перенос строки
            [ ! $((($i - 15) % 6)) -eq 0 ] && printf ' ' || printf '\n'
        done
    fi
}

demo_256_colour

# For example:
# printf "\033[38;5;087m we liked 087 in printf style\n"
# echo -e "\033[38;5;087m or liked it in echo style"
