Впоследствии данный файл послужит источником для скриптов автоматической настройки рабочего места.<br>

## CLI
Для ускорения, оптимизации работы и использования в скриптах:<br>
* **curl**
* **git**
* **gpg** - GNU Privacy Guard - шифрование файлов
* **jq** - a command-line JSON processing tool.
* **yamllint**
* **python3.8**
* **locate** - для быстрого и удобного поиска файлов на локальном АРМ.
* **wget**
* **openssh-server**
* **zsh** - пока использую в качестве эксперимента на личном АРМ.
* **tree**
* **kafkacat** - если используется Apache Kafka

## GUI
Если используется Desktop Environment:<br>
* **xdg-utils** [Краткий справочник](https://packages.debian.org/ru/sid/xdg-utils)
* **xclip** [Полезные скрипты на будущее](https://habr.com/ru/articles/48954/)
* **flameshot** программа для быстрых, аккуратных и наглядных скриншотов.
* **graphviz** программа для рисования графов в терминале на языке dot.
* **wireshark** - для анализа данных по сети.
* **okular** - программа для разметки pdf, djvu, etc. документов
* **vim-gtk or vim-gnome** (На Debian или Ubuntu) - убедиться, что поддерживается системный буфер обмена для копирования текстов. Проверка:
```
vim --version | grep clipboard
```
Должны отображаться: **+clipboard** или **+xterm\_clipboard**
