# Немного о дебаге

В состав Istio входят Zipkin и Jaeger – популярные распределенные системы трассировки с открытым кодом для хранения, агрегирования и интерпретации данных.

ControlZ - гибкий фреймворк интроспекции, позволяющий исследовать и изменять внутреннее состояние компонентов Istio.<br>
При запуске компонентов Mixer, Pilot, Citadel и Galley в журнал записывается сообщение с указанием IP-адреса и порта подключения для взаимодействия с ControlZ. (До 1.5 версии istio)

Meshery?

## Обязательные пререквизиты
Портам сервисов должны быть присвоены имена.<br>
Чтобы использовать механизм маршрутизации трафика в Istio, для каждого сервиса должны быть определены пары ключ/значение, включающие имя порта и протокол, согласно синтаксису:<br>
name: <protocol>[-<suffix>].<br>
Для <protocol> можно использовать одно из следующих значений (в виде строки):<br>
* grpc;
* http;
* http2;
* https;
* mongo;
* redis;
* tcp;
* tls;
* udp.

Привяжите все поды хотя бы к одному сервису.<br>
Открывается порт или нет, все поды должны принадлежать, по крайней мере, одному сервису Kubernetes.<br>
Для подов, принадлежащих нескольким сервисам Kubernetes, убедитесь, что каждый сервис определяет один и тот же тип протокола при обращении к одному и тому же номеру порта.<br>

Конфигурация пода должна допускать использование NET_ADMIN.<br>
При внедрении прокси сетка Istio использует контейнер init, устанавливающий правила iptables в поде для перехвата запросов к контейнерам приложений. Хотя прокси не требует привилегий root для выполнения, но контейнеру init нужны привилегии **cap_net_admin** для установки правил iptables в каждом поде непосредственно перед запуском основных контейнеров пода в сервисной сетке.<br>

## Информация по чтению логов envoy
[envoy response code](https://www.envoyproxy.io/docs/envoy/latest/configuration/http/http_conn_man/response_code_details)<br>
[envoy observability logs](https://www.envoyproxy.io/docs/envoy/latest/configuration/observability/access_log/usage)<br>
[envoy change log level](https://docs.tetrate.io/envoy-gateway/administration/debug-logs)

