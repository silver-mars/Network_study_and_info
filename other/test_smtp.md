Пользователь готовит сообщение с помощью установленного почтового агента **агента пользователя**,
передаёт его на почтовый сервер (агент передачи почты - **mail transfer agent**.
Далее MTA определяет получателя, ищет почтовый сервер, который обслуживает получателя и передаёт сообщение на этот почтовый сервер.
Для передачи сообщений между MTA используется SMTP.
Когда сообщение добралось до почтового сервера, обслуживающего пользователя, запускается программа **агент доставки почты**, которая копирует сообщение в **хранилище сообщений** - почтовый ящик на сервере, где письма хранятся и ожидают, когда пользователь за ними обратится.
Получатель, с помощью **агента пользователя** (который может быть локальным клиентом или web-интерфейсом), обращается к **хранилищу сообщений**, читает оттуда адресованные ему письма и может уже что-то с ними делать.

В электронной почте используются три протокола:
**SMTP** - для передачи сообщений как от агента пользователя почтовому серверу, так и от MTA к MTA.
**POP3, IMAP** - Post Office Protocol 3 and Internet Message Access Protocol.

# SMTP protocol

SMTP (Simple Mail Transfer Protocol) – простой протокол передачи почты.

Версии SMTP:
* Протокол SMTP был создан в 1982 году.
* Расширение SMTP (ESMTP, Extended SMTP) - 2008 год.

В стеке TCP/IP протокол SMTP находится на прикладном уровне.
Теоретически SMTP может использовать любой транспортный протокол:
* TCP
* UDP
* и дрегие.

**Порты SMTP:**
Порт 25 – передача почты между почтовыми серверами
Порт 587 – прием почты от клиентов
Однако на практике почти всегда используется только протокол TCP, порт 25.

**Формат**
Электронное письмо состоит из трех частей:
* Конверт.
Команды протокола SMTP находятся только в конверте.
Именно конверт используется при передаче почты между серверами и почтовыми клиентами.
Данные в конверте определяют **как** почта будет передаваться.
* Заголовок.
* Тело письма.

SMTP работает в текстовом режиме (нет специального формата пакета), между клиентом и сервером используется взаимодействие типа запрос-ответ.

Команды SMTP состоят из 4-ёх символов: (расшифровка + пример)
* HELO/EHLO - установка соединения
HELO example.com
* MAIL FROM - адрес отправителя
MAIL FROM: sender@example.com
* RCPT TO - адрес получателя
RCPT TO: recipipient@mail.ru
(одно и то же письмо можно отправлять нескольким получателям, для этого эту команду нужно использовать несколько раз).
* DATA - начало передачи письма (конверт закончился, дальше - данные)
DATA
* QUIT - разрыв соединения с сервером после того, как передача письма завершена.
QUIT

**Ответы SMTP**
SMTP использует код и некоторое текстовое сообщение, поясняющее что произошло.
Как и в HTTP - коды, начинающиеся на двойку - успех.

Код Назначение                              Пример
220 Подключение к серверу успешно           220 smtp.example.com ESMTP Postfix
250 Успешное выполнение предыдущей команды  250 Hello example.com 250 Ok
354 Начало передачи письма                  354 End data with <CR> <LF>.<CR> <LF>
502 Команда не реализована                  502 5.5.2 Error: command not recognized
503 Неправильная последовательность команд  503 5.5.1 Error: need MAIL command
221 Закрытие соединения                     221 2.0.0. So long, and thanks for all the fish

**Заголовки письма**
Формально они не являются частью стандарта SMTP.

Заголовок   Назначение
From:       Отправитель (имя и адрес)
To:         Получатель
CC:         Получатель копии письма
BCC:        Получатель копии, адрес которого не должен быть показан
Reply-To:   Адрес для ответа
Subject:    Тема письма
Date:       Дата отправки письма

Пример сеанса SMTP:

220 smtp.example.ru ESMTP Postfix
Helo etamol.ru
250 smtp.example.tu
MAIL FROM: name@etamol.ru
250 2.1.0 Ok
RCPT TO: reciever@example.ru
250 2.1.5 Ok
DATA
354 End data with <CR> <LF>.<CR> <LF> - приглашение вводить текст письма, которое должно закончиться отдельной строкой с символом точки.
// далее - само письмо, состоящее из заголовков и текста:
From: takoy-to takoy-to <awe@kin.ru>
Subject: An Example of SMTP
// Тело сообщения должно быть отделено от заголовков пустой строкой.
Hello, email world!
Hello, SMTP!
.

250 2.0.0 Ok: queued as 7FD9DC2E0060
QUIT
221 2.0.0 Bye

# Расширение SMTP (ESMTP)
* Появился в 2008 году

**Новые команды**
* EHLO - Extended HELO
* STARTTLS - использование шифрования
* SIZE - объявление максимально возможного размера письма (или узнать какой макс. размер принимает почтовый сервер)
* DSN - подтверждение о доставки письма

**Набор символов**
* SMTP мог использовать только 7-битные наборы символов
* ESMTP допускает использование 8-битных наборов символов (можно передавать русские буквы)

**Безопасность и спам**
SMTP не содержит механизмов защиты данных
* Содержимое полей MAIL FROM и FROM никак не контролируется (могут отличаться и можно указывать что отправителем является другой адрес)
* Данные передаются по сети в открытом виде (кроме использования STARTTLS)

Так же есть проблема со **спам**
* Рассылка нежелательных сообщений, как правило рекламных
Протокол не содержит механизмов защиты от спама.

**Защита от спама:**
* Проверка домена отправителя через DNS
* Почтовые серверы принимают письма только для локальных получателей
* Проверка адреса отправителя с помощью цифровой подписи

Пример работы.

0. Узнаём свой адрес почтового сервера:
nslookup
> set type=MX
> a.boycov@aaa.my-inform.ru
> жмём Enter. В выводе будет что-то вроде этого:

Non-authoritative answer:
aaa.my-inform.ru	mail exchanger = 10 mail.aaa.my-inform.ru.

Authoritative answers can be found from:
mail.aaa.my-inform.ru	internet address = <ip-address>

1. Выполняем команду:
**telnet mail.aaa.my-inform.ru 25**
Output:
Trying <ip-address>...

Connected to mail.aaa.my-inform.ru.
Escape character is '^]'.
220 mail.aaa.my-inform.ru ESMTP

2. Указываем свой домен:
EHLO aaa.my-inform.ru (без mail впереди!)
(нам выдают список доступных команд, вида:)
250-mail.aaa.my-inform.ru
250-PIPELINING
250-SIZE 31457280
250-ETRN
250-STARTTLS
250-AUTH PLAIN LOGIN
250-ENHANCEDSTATUSCODES
250-8BITMIME
250 DSN

3. Указываем свой рабочий почтовый адрес:
MAIL FROM: a.bychkov@aaa.my-inform.ru
output:
250 2.1.0 Ok

4. Указываем почтовый адрес получателя:
RCPT TO: v.name@aaa.my-inform.ru

5. Указываем, что хотим ввести письмо:
DATA

6. Указываем заголовки, пишем тело письма.
From: Моё Имя <a.bychkov@aaa.my-inform.ru>
Subject: Привет из консоли

Это письмо отправлено из терминала командой telnet с использованием протокола SMTP.
Проверяем доберётся ли оно до тебя.
__
С уважением,
такой-то такой-то
.

Output:
250 2.0.0 Ok: queued as 88C6E3FA8A
7. Выходим
QUIT
221 2.0.0 Bye
Connection closed by foreign host.

# Simple kub commands:
feature alpha debug
Starting with 3.21 version only debug:
kubectl debug -n svs-test front-filter-6775b6fd8c-zh8fw -it --image=busybox --target=front-filter -- /bin/sh
