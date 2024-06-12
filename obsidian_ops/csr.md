# Генерация ключа
**Предварительный глоссарий.**<br>
1. Один из наиболее распространённых форматов, с которыми мы работаем - это формат PEM.<br>
**PEM** — это текстовое представление реального двоичного ключа или сертификата в формате DER.<br>
Представляет собой двоичный формат DER в кодировке base64 с дополнительными строками:<br>
«——BEGIN PRIVATE KEY——», «——BEGIN CERTIFICATE——» и другими в начале файла<br>
и строками<br>
«——END PRIVATE KEY——», «——END CERTIFICATE——» в конце файла.<br>
2. В пакете OpenSSL есть две команды, которые выполняют очень похожее действие — генерируют пару приватный-публичный ключ RSA:<br>
**openssl genpkey -algorithm RSA**<br>
and<br>
**openssl genrsa**<br>
обе команды генерируют приватные ключи, но **genpkey** по сути заменяет **genrsa, gendh** и **gendsa**<br>
Так что самая простая команда генерации ключа выглядит так:<br>
```
openssl genpkey -algorithm RSA -out your_key.key
```
Опция **-out** указывает на имя файла для сохранения, без этой опции файл будет выведен в стандартный вывод (на экран).<br>
Имя выходного файла не должно совпадать с именем входного файла.<br>

# Генерации запроса на сертификат
В общем виде команда выглядит так:
```
openssl req -newkey rsa:2048 -sha256 -nodes -config config.cnf -out kafka.csr -keyout kafka.key
```
**Используемые опции:**
1. openssl-req:<br>
**nodes/noenc**<br>
 - -nodes (This option is deprecated since OpenSSL 3.0; use -noenc instead).
 - -noenc (If this option is specified then if a private key is created it will not be encrypted).<br>
Указывает, что приватному ключу не нужно задавать парольную фразу.<br>
В случае, если эту опцию опустить, во-первых, у ключа в формате PEM заголовок и концевик будут иметь дополнительный маркер encrypted:<br>
-----BEGIN ENCRYPTED PRIVATE KEY-----<br>
-----END ENCRYPTED PRIVATE KEY-----<br>
Во-вторых, при команде
```
openssl rsa -in kafka.key
```
Будет запрошена заданная при создании парольная фраза. При её успешном введении заголовок и концевик будут изменены на:<br>
-----BEGIN PRIVATE KEY-----<br>
-----END PRIVATE KEY-----<br>
И ключ будет расшифрован корректно.<br>

2. **-new**:<br>
Эта опция генерирует создание файл запроса на подпись сертификата — Certificate Signing Request (CSR).<br>

**-newkey args [rsa:nbit - example]**<br>
-newkey rsa:2048<br>
newkey указывает, что нужно создать новую пару ключей, а в параметрах мы сообщаем тип rsa и сложность 2048 байт<br>
опция **-new** указывает что нужно создать запрос csr.<br>
Т. е. фактически - это замена:<br>
```
openssl req -key domain.key -new -out domain.csr
```

# Инфа о файле конфиг будет здесь.
