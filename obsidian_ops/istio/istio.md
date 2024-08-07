# ISTIO

В общем и целом архитектура сервисных сеток, включая Istio, делится на два уровня:<br>
**уровень управления** и **уровень данных**.<br>
Третий уровень (**уровень администрирования**) может располагаться в существующих/инфраструктурных системах. Архитектура Istio тоже следует этой парадигме:<br>
* **Уровень администрирования**<br>
(руководство, финансовое управление, расширенная интеграция политики и систем, учёт, объединение, интеллектуальные сервисы, группы сеток)<br>
* **Уровень управления**<br>
(мониторинг, настройка политики, топология сети / состояние, обнаружение сервисов, управление идентификацией)<br>
* **Уровень данных**<br>
(переадресация пакетов, маршрутизация, балансировка нагрузки, кеширование, облегчение соблюдения политики).<br>

**Уровни данных** отвечают за связь внутри кластера, а также обработку входящего и исходящего трафиков кластера. Уровень данных Istio анализирует каждый пакет/запрос в системе и отвечает за обнаружение сервисов, проверку работоспособности, маршрутизацию, балансировку нагрузки, аутентификацию, авторизацию и наблюдаемость.<br>
Уровень управления Istio предоставляет единую точку администрирования прокси для эффективного управления их настройками в режиме реального времени. Уровни управления отвечают за определение политик и настройку сервисов в сетке, объединяя вместе изолированные прокси и превращая их в сервисную сетку. Уровни управления не анализируют сетевые пакеты непосредственно; они работают вне сервисной сетки. Для взаимодействия с ними обычно предоставляется графический интерфейс и интерфейс командной строки.<br>
**Уровень управления Istio**:<br>
* предоставляет политику и конфигурацию сервисам в сетке через API и позволяет администраторам задать требуемое поведение маршрутизации/отказоустойчивости;<br>
* Объединяет набор изолированных прокси в сервисную сетку и **предоставляет уровню данных**:<br>
  - API для передачи локализованной конфигурации;<br>
  - абстракцию обнаружения сервисов;<br>
* использует API для определения политик через назначение квот и ограничений;<br>
* обеспечивает безопасность посредством выдачи и ротации сертификатов;<br>
* назначает идентификатор рабочей нагрузке;<br>
* обрабатывает конфигурацию маршрутизации:<br>
  - не анализирует никакие пакеты/запросы в системе;<br>
  - определяет границы сетей и способы доступа к ним;<br>
  - унифицирует сбор телеметрических данных.<br>

## Компоненты уровня управления Istio

### Pilot
Pilot находится в постоянном контакте с базовой платформой (например, Kubernetes), наблюдает за состоянием и местоположением запущенных сервисов и предоставляет эту информацию уровню данных.<br>
Pilot взаимодействует с системой обнаружения сервисов и отвечает за настройку прокси.<br>

Pilot обслуживает Envoy-совместимые конфигурации путём объединения информации о конфигурации и конечных точках из различных источников и преобразования её в объекты xDS.<br>
xDS (Extensible Discovery Service) is a communication protocol used for managing service discovery and dynamic configuration in a microservices architecture.<br>
This mechanism is widely used in Envoy proxies and Istio service meshes to manage various types of resource configurations, such as routing, service discovery, load balancing settings, etc.<br>

xDS includes the following main discovery services, each responsible for different types of network resources configurations:<br>
* SDS (Secret Discovery Service): Manages security-related configurations, such as TLS certificates and private keys.<br>
Example:<br>
2024-08-01T12:01:43.298922Z	info	sds	Starting SDS grpc server<br>
2024-08-01T12:01:44.189439Z	info	ads	SDS: PUSH request for node:pod-name.namespace-name resources:1 size:4.0kB resource:default<br>
2024-08-01T12:01:44.190503Z	info	ads	SDS: PUSH request for node:pod-name.namespace-name resources:1 size:1.1kB resource:ROOTCA<br>
* ADS (Aggregated Discovery Service): A single gRPC stream aggregates all types of incremental data<br>

### Galley
Galley является компонентом агрегации и распределения конфигурации Istio. По мере развития своей роли он будет изолировать другие компоненты Istio от нижележащих платформ и поставляемых пользователем конфигураций, принимая и проверяя их.<br>
Galley использует протокол настройки сетки (Mesh Configuration Protocol, MCP) в качестве механизма обслуживания и распределения конфигураций.<br>

### Mixer
Mixer может работать самостоятельно и представляет собой компонент уровня управления, разработанный для абстрагирования других инфраструктурных компонентов Istio, таких как Stackdriver или New Relic. Mixer отвечает за предварительную проверку условий, управление квотами, передачу телеметрии, а также:<br>
* обеспечивает мобильность платформы и окружения;
* обеспечивает тщательный контроль за операционной политикой и телеметрией, отвечая за оценку политики и передачу телеметрических данных;
* имеет обширные настройки;
* абстрагирует большинство инфраструктурных задач с помощью конфигурации на основе намерений (intent-based configuration)

Прокси сервисы и шлюзы обращаются к Mixer для выполнения предварительных проверок, чтобы определить, разрешено ли выполнение запроса (проверка), разрешена ли связь между вызывающим абонентом и сервисом, не превышены ли квоты, а также для передачи телеметрии после обработки запроса (отчёт).<br>
Mixer взаимодействует с компонентами инфраструктуры через набор встроенных и сторонних адаптеров.<br>
Конфигурация адаптера определяет, когда и к какому компоненту отправлять телеметрию.<br>

### Citadel
Citadel позволяет Istio обеспечить надёжную аутентификацию между сервисами и конечными пользователями с помощью протокола двусторонней защиты транспортного уровня (mutual Transport Layer Security, mTLS) со встроенной идентификацией и управлением учётными данными.<br>
Компонент CA Citadel утверждает и подписывает запросы, отправляемые агентами Citadel, и выполняет генерацию, развёртывание, ротацию и аннулирование ключей и сертификатов.<br>
Citadel имеет расширяемую архитектуру, позволяя использовать различные центры сертификации вместо самосозданных, самоподписанных ключей и сертификатов для подписи сертификатов рабочей нагрузки.<br>
Возможность подключения центра сертификации Istio позволяет и облегчает:<br>
* интеграцию с системой открытых ключей (PKI) в вашей организации;
* защиту связи между доверенными сервисами Istio и не-Istio (используя один и тот же корень доверия (root of trust));
* защиту ключа подписи CA, храня его в хорошо защищённой среде (например, HashiCorp Vault, аппаратный модуль безопасности, или HSM).
Hardware Security Module (HSM) - специализированное вычислительное устройство, которое обеспечивает защиту и управление секретной информацией (в первую очередь цифровыми ключами), выполняет функции шифрования и дешифрования для цифровых подписей, надёжной аутентификации и других криптографических функций.<br>

## Шлюзы
Настройка входных шлюзов позволяет определить точки в сервисной сетке, через которые будет проходить внешний трафик.<br>
Обработка входящего в сетку трафика - это задача обратного проксирования, похожая на традиционную балансировку нагрузки веб-сервера.<br>
Настройка обработки исходящего из сетки трафика - это задача прямого проксирования, при решении которой определяется, какому трафику разрешено покинуть сетку и куда он должен направляться.<br>
