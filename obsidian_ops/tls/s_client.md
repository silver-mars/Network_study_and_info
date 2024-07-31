# S_client
## Основные возможности
Опция s_client выполняет функции SSL/TLS клиента для подключения к удалённому хосту с различными настройками — ключ шифрования, вид рукопожатия, протокол и т. д.<br>
(SSL/TLS client program)<br>

Вывод включает в себя информацию о цепочке сертификатов для сервера, выводит дополнительную информацию о subject, issuer, Common Name и т. д.<br>
The end entity (сущность, объект, элемент) server certificate will be the only certificate printed in PEM format.<br>
Details about the SSL handshake, its verification, and the TLS version and cipher will be returned. The server’s public key bit length is also returned.<br>

Базовый синтаксис подключения выглядит следующим образом:
```
openssl s_client -connect example.ru:443
```
Пример вывода (начало):
```
CONNECTED(00000003)
depth=2 C = RU, O = Something Org, CN = CA Sand Root Ext
verify error:num=20:unable to get local issuer certificate
verify return:1
depth=0 C = RU, O = Something Org, OU = 001, CN = example.ru
verify return:1
```
Ключевой момент, на который нужно обращать внимание:<br>
не должно быть **verify error**<br>
должны быть **verify return: 1** (цепочка сертификатов прошла все базовые проверки)<br>

Где-то в середине/ближе к концу есть блок, сообщающий об успешности или неуспешности подключения:
```
---
SSL handshake has read 4185 bytes and written 400 bytes
Verification error: unable to get local issuer certificate
---
```
или
```
---
SSL handshake has read 4185 bytes and written 400 bytes
Verification: OK
---
```
Для того, чтобы увидеть корневой сертификат, которому доверяет данный сайт, нужно добавить опцию **-showcerts**.<br>
Таким образом вся команда приобретает вид:
```
openssl s_client -connect example.ru:443 -showcerts
```

## Какие ошибки могут встречаться?
```
verify error:num=20:unable to get local issuer certificate
```
Это означает, что не хватает правильно сформированной цепочки корневых сертификатов.<br>
("I can't follow the certificate chain to a trusted root").<br>
**Решение:**
Помогает отладка через консоль с указанием хоста, порта и либо пути к директории, содержащей корневые сертификаты:
```
openssl s_client -connect example.ru -port 443 -CApath ~/path/to/chain_root_certs/
```
Либо отладка с опцией -CAfile с явным указанием файла с цепочкой сертификатов:
```
openssl s_client -connect example.ru -port 443 -CAfile ~/path/to/chain_root_certs/chain.crt
```
в идеале при подборе правильного сертификата вы должны увидеть подписи:<br>
**verify return:1** под каждым сертификатом.<br>
Это означает, что цепочка сертификатов прошла все базовые проверки.<br>
Пример:
```
CONNECTED(00000003)
depth=2 C = RU, O = Something Org, CN = CA Sand Root Ext
verify return:1
depth=1 C = RU, O = Something Org, CN = CA Sand Inter
verify return:1
depth=0 C = RU, O = Something Org, OU = 001, CN = example.ru
verify return:1
---
```
## Extra options
debug with pkey:
```
openssl s_client -connect 10.106.10.122 -port 443 -tlsextdebug -key egress_private_key.pem
```
