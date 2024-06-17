Впоследствии данный файл послужит источником для скриптов автоматической настройки рабочего места.<br>

## CLI
Для ускорения, оптимизации работы и использования в скриптах:<br>
* **curl**
* **git**
* **locate** - для быстрого и удобного поиска файлов на локальном АРМ.
* **openssh-server**
* **jq** - a command-line JSON processing tool.
* **zsh** - пока использую в качестве эксперимента на личном АРМ.
* **tree**
* **kafkacat** - если используется Apache Kafka

## GUI
Если используется Desktop Environment:<br>
* **xdg-utils** [Краткий справочник](https://packages.debian.org/ru/sid/xdg-utils)
* **xclip** [Полезные скрипты на будущее](https://habr.com/ru/articles/48954/)
* **flameshot** программа для быстрых, аккуратных и наглядных скриншотов.
* **wireshark** - для анализа данных по сети.<br>
* **vim-gtk or vim-gnome** (На Debian или Ubuntu) - убедиться, что поддерживается системный буфер обмена для копирования текстов. Проверка:
```
vim --version | grep clipboard
```
Должны отображаться: **+clipboard** или **+xterm\_clipboard**
