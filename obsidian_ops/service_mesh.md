# Service Mesh

Сервисные сетки обеспечивают **обслуживание сетевых рабочих нагрузок** на основе политик, гарантируя **требуемое поведение** сети **при постоянном изменении условий и топологии**.<br>
То есть поведение остаётся неизменным при изменениях нагрузки, конфигураций, ресурсов (сюда включаются те, которые влияют на инфраструктуру и топологию приложений, в том числе внутри- и межкластерные ресурсы, то появляющиеся, то исчезающие), и развертываются новые рабочие нагрузки.

**Преимущества:**<br>
Микросервисы превратили внутренние коммуникации приложений в сетку, **сплетенную из вызовов удаленных процедур (RPC)** между сервисами, передаваемых по сетям.<br>
Среди преимуществ микросервисов – демократизация выбора языка и технологий в независимых сервисных группах.<br>
Сервисные сетки могут выглядеть как реинкарнация программно определяемой сети (SDN), но отличаются в первую очередь ориентацией на разработчика, а не на администратора сети.<br>
Термин **«целевой нетворкинг» (intent-based networking)** используется в основном в физических сетях, но, учитывая декларативный контроль на основе политик, предоставляемый сервисными сетками, справедливо сравнить их с истинно облачными **SDN.**<br>

## Архитектура сервисных сеток
1. **Административный уровень:**
* Общее руководство, возможно несколькими сетками и кластерами, определение общих политик и системная интеграция, умные сервисы, объединение
2. **Уровень управления:**
* Обеспечивает политику, конфигурацию и интеграцию платформ
* Собирает набор изолированных прокси в сервисную сетку
* Не касается пакетов/запросов в пути данных
3. **Уровень данных: (ingress -> envoy -> egress)**
* Работает с каждым пакетом в системе
* Отвечает за обнаружение сервисов, проверку работоспособности, маршрутизацию, балансировку нагрузки, аутентификацию, авторизацию и мониторинг

## Прокси-сервисы в сервисных сетках
Сервисные сетки строятся с использованием **прокси сервисов**. 

Прокси сервисы находятся на уровне данных и передают трафик. Трафик прозрачно перехватывается с помощью правил iptables в пространстве имен подов.<br>
Такой унифицированный слой инфраструктуры в сочетании с развернутыми сервисами обычно называют сервисной сеткой (service mesh).<br>
Istio превращает разрозненные микросервисы в интегрированную сервисную сетку, внедряя прокси сервисы во все сетевые пути, устанавливая соединения между прокси и ставя их под централизованный контроль, таким образом формируя сервисную сетку.<br>
Размещение прокси возле каждого экземпляра приложения избавляет от необходимости иметь специфические библиотеки отказоустойчивости для разрыва цепи, тайм-аутов, повторных попыток, обнаружения сервисов, балансировки нагрузки и т. д.

## Как могут развёртываться
Сервисные сетки могут развертываться отдельным уровнем поверх оркестраторов контейнеров, но не требуют их, поскольку компоненты уровней управления и данных могут быть развернуты независимо от инфраструктуры контейнеров. Также агент узла (включая прокси), как компонент уровня данных, часто используется в неконтейнерных окружениях.

## Как сервисные сетки дополняют оркестраторы контейнеров
Будучи универсальными по своей природе, оркестраторы контейнеров отвечают за формирование кластеров, эффективное распределение своих ресурсов и высокоуровневое управление приложениями (развертывание, обслуживание, оценка близости/удаленности, проверка исправности, масштабирование и т. д.).<br>
Ниже показаны возможности оркестраторов контейнеров (звездочками отмечены наиболее важные из них). Сервисные сетки, как правило, полагаются на нижележащие слои. В данном случае нижний уровень образуют оркестраторы контейнеров.
**Основные возможности оркестраторов контейнеров:**
* Управление кластерами\*
  - Обнаружение хостов
  - Мониторинг работоспособности хостов
* Планирование\*
* Обновление оркестраторов и обслуживание хостов
* Обнаружение сервисов\*
* Поддержка сети и балансировка нагрузки
* Сервисы с состоянием
* Поддержка работы в многопользовательском и мультирегиональном режимах

**Сеть уровня сервисов:**
Неудовлетворенные потребности уровня сервисов
* Обрыв цепи
* Маршрутизация гранулированного трафика L7
- Переадресация HTTP
- Управление CORS
* Хаотичное тестирование
* Канареечные развертывания
* Тайм-ауты, повторы, бюджеты, сроки
* Маршрутизация по запросу
* Обратное давление
* Безопасность транспортировки (шифрование)
* Идентификация и управление доступом
* Управление квотами
* Перевод протоколов (REST, GRPC)
* Политики
* Мониторинг производительности сервисов

Поддерживаемые оркестраторами контейнеров алгоритмы балансировки нагрузки, как правило, просты по своей природе (циклические, случайные) и действуют под одним виртуальным IP-адресом для взаимодействия с внутренними подами.<br>
Kubernetes занимается регистрацией/вытеснением экземпляров в группе на основании их работоспособности и соответствия предикату группы (меткам и селекторам). Далее, сервисы могут использовать DNS для обнаружения сервисов и балансировки нагрузки вне зависимости от их реализации. Нет необходимости в специальных библиотеках, зависящих от языка, или в регистрации.<br>
Контейнерные оркестраторы позволили переместить рутинные сетевые задачи из приложений в инфраструктуру, освободив общую технологическую экосистему инфраструктуры и переместив акцент на более высокие уровни.

## Сервисные сетки и API-шлюзы

API-шлюзы удовлетворяют ряд схожих потребностей и обычно развертываются в оркестраторах в качестве пограничного прокси. Пограничные прокси предоставляют управление уровнями с 4 **(L4)** по 7 **(L7)** и используют оркестраторы контейнеров для обеспечения надежности, доступности и масштабируемости контейнерной инфраструктуры.<br>
**API-шлюзы** взаимодействуют с сервисными сетками способом, озадачивающим многих, поскольку API-шлюзы (и прокси, на которых они основаны) варьируются от традиционных до облачных API-шлюзов и API-шлюзов микросервисов. Последние могут быть представлены коллекцией API-шлюзов с открытым исходным кодом для микросервисов, которые обертывают существующие прокси уровня L7, интегрированные с  оркестраторами контейнеров и средствами самообслуживания разработчика (например, **HAProxy, Traefik, NGINX или Envoy**).

Главной задачей API-шлюзов в сервисных сетках является прием трафика извне и его распределение внутри.<br>
API-шлюзы образуют управляемый API для доступа к сервисам и ориентированы на передачу вертикального трафика (входящего и исходящего из сервисной сетки).<br>
Они не так хорошо подходят для управления горизонтальным трафиком (внутри сервисной сетки), так как им требуется, чтобы трафик проходил через центральный прокси, а это добавляет лишний сетевой переход.<br>
Сервисные сетки, напротив, предназначены в первую очередь для управления горизонтальным трафиком внутри сервисной сетки.

Учитывая их взаимодополняющий характер, API-шлюзы и сервисные сетки часто устанавливаются совместно.

## Требования к сети

Как уже отмечалось, в комплексе действующих микросервисов сеть непосредственно вовлечена в каждую транзакцию, в каждое обращение к бизнес-логике и в каждый запрос, сделанный к приложению. Надежность сети и задержки являются одними из главных проблем современных облачных приложений.<br>
Одно истинно облачное приложение может включать сотни микросервисов, со множеством экземпляров каждого, постоянно меняющихся оркестратором контейнеров по расписанию.<br>
Учитывая центральную роль сети, желательно, чтобы она была как можно более интеллектуальной и отказоустойчивой.

Сеть должна:
* маршрутизировать трафик в обход отказов для повышения совокупной надежности кластера;
* избегать нежелательных издержек, возникающих, например, при выборе маршрутов с высокой задержкой или серверов с холодным кэшем;
* обеспечить защиту межсервисного трафика от тривиальной атаки;
* помогать в выявлении проблем, выделяя неожиданные зависимости и первопричины сбоев в коммуникациях;
* разрешать определять политики не только на уровне соединений, но и на уровне поведения сервисов.<br>
Необходимо управление на уровне L5, то есть сеть, ориентированная на сервисы; проще говоря – сервисная сетка.

## Преимущества сервисной сетки

**Наблюдаемость**<br>
Сервисные сетки обеспечивают видимость, отказоустойчивость и контроль трафика, а также контроль безопасности распределенных сервисов приложений. Это весомые преимущества. Сервисные сетки разворачиваются прозрачно и обеспечивают видимость и контроль трафика без необходимости внесения каких-либо изменений в код приложения.

**Управление трафиком**<br>
Сервисные сетки обеспечивают детальный, декларативный контроль над сетевым трафиком, например позволяя определить направление запроса на выполнение канареечного развертывания. В число функций поддержки надежности обычно входят: разрыв цепи, балансировка нагрузки с учетом задержек, согласованное обнаружение сервисов, повторы, тайм-ауты и критические сроки.

**Безопасность**<br>
В лице сервисных сеток организации получают мощный инструмент управления безопасностью, политиками и требованиями. Большинство сервисных сеток предоставляют центр сертификации (CA, Certificate Authority) для управления ключами и сертификатами в обеспечение связи между сервисами. Присвоение каждому сервису в сетке проверяемой идентичности является ключом к определению клиентов, имеющих право выполнять запросы к  различным сервисам, а также для шифрования трафика, порождаемого этими запросами.<br>
Сертификаты генерируются для каждого сервиса и представляют его уникальную идентичность. Обычно для идентификации сервисов и управления жизненным циклом сертификатов (генерация, распределение, обновление и отзыв) от их имени используются соответствующие прокси.

**Развязка на уровне 5**<br>
Предоставляет администраторам декларативный контроль над работой сервисов.<br>
Плюс предоставляет общую наблюдаемость разработчикам.<br>
Рассмотрим следующий список заданий:
* определить, когда разрывать связь и упростить процесс;
* установить предельные сроки обслуживания;
* гарантировать генерирование распределенных трассировок и их передачу в системы мониторинга;
* запретить пользователям аккаунта «Рога и копыта» доступ к бета-версиям сервисов.<br>
Всё это конфигурируется в настройках сервисной сетки, предоставляя больше возможностей для управления трафиком в том числе на сеансовом уровне L5 OSI.

Сервисные сетки внедряют в первую очередь для контроля с применением средств мониторинга сетевого трафика.<br>
Многие учреждения, особенно финансовые, используют сервисные сетки прежде всего для управления шифрованием межсервисного трафика.

## Istio

Istio (греч. ιστίο) – это греческое слово «парус».
**То, чем Istio не является**<br>
Istio лишь упрощает распределенную трассировку, но не является решением для мониторинга производительности white box (полностью известных) приложений (application performance monitoring, APM).<br>
Способы генерации дополнительной телеметрии, сопровождающей и анализирующей сетевой трафик и сервисные запросы, доступные в Istio, обеспечивают дополнительную видимость black box, объектов с неизвестными/необъявленными параметрами. Из всех метрик и журналов, доступных в Istio, эта телеметрия позволяет получить представление о потоках сетевого трафика, включая источник, приемник, задержки и ошибки; метрики сервисов высшего уровня, но нестандартные метрики приложений, которые генерируют рабочие нагрузки по отдельности, а также журналы уровня кластера остаются недоступными.

## Глоссарий
* Облако (cloud)<br>
Специализированный провайдер облачных сервисов.
* Кластер (cluster)<br>
Набор узлов Kubernetes с общим API.
* Хранилище конфигурации (config store)<br>
Система, хранящая конфигурацию вне уровня управления, например etcd в сервисной сетке Istio, развернутой в Kubernetes, или даже в простой файловой системе.
* Управление контейнерами (container management)<br>
Программные стеки виртуализации операционных систем, такие как Kubernetes, OpenShift, Cloud Foundry, Apache Mesos и другие.
* Окружение (environment)<br>
Вычислительная среда от поставщиков инфраструктуры как услуги (IaaS), таких как Azure Cloud Services, AWS, Google Cloud Platform, IBM Cloud, Red Hat Cloud Computing, или группа виртуальных/физических машин, работающих в локальных/удаленных центрах обработки данных.
* Сетка (mesh)<br>
Ряд рабочих нагрузок с общим административным управлением в рамках одного и того же руководящего органа (например, уровня управления).
* Мультисреда (гибрид) (Multienvironment, hybrid)<br>
Неоднородный набор окружений, каждое из которых может отличаться от других реализацией и способом развертывания следующих инфраструктурных компонентов:
  - Границы сети (network boundaries)<br>
Пример: один компонент доступен в местной сети, а другой – в облаке.
  - Системы идентификации (Identity systems)<br>
Пример: один компонент использует LDAP, другой – учетные записи сервисов.
  - Системы разрешения имен, такие как DNS (Naming systems)<br>
Пример: локальный DNS, DNS на базе Consul.
  - VM / контейнер / фреймворки управления процессами (VM / container / process orchestration frameworks)<br>
Пример: один компонент имеет локально управляемые VM, а другой - контейнеры, управляемые Kubernetes.
* Множественная аренда (Multitenancy)<br>
Логически изолированные, физически интегрированные сервисы, работающие под одним уровнем управления сервисной сетки Istio.
* Сеть (Network)<br>
Набор непосредственно связанных между собой конечных точек (может включать виртуальную частную сеть [VPN]).
* Безопасное разрешение имен (Secure naming)<br>
Обеспечивает сопоставление между именем сервиса и субъектами рабочих нагрузок, уполномоченными на выполнение рабочих нагрузок, реализующих сервис.
* Сервис (Service)<br>
Определенная группа взаимосвязанных линий поведения в рамках сервисной сетки. Сервисы имеют имена, а политики Istio, такие как балансировка нагрузки и маршрутизация, применяются к именам сервисов. Обычно сервис имеет одну или несколько конечных точек, доступных извне.
* Конечная точка сервиса (Service endpoint)<br>
Достижимое по сети представление сервиса. Конечные точки экспортируются рабочими нагрузками. Не все сервисы имеют конечные точки, доступные извне.
* Сервисная сетка (Service mesh)<br>
Общий набор имен и идентификационных данных, позволяющий обеспечить применение общих политик и сбор телеметрии. Имена сервисов и субъект рабочей нагрузки уникальны в пределах одной сетки.
* Имя сервиса (Service name)<br>
Уникальное имя сервиса, идентифицирующее его в пределах сети сервисов.<br>
Сервис нельзя переименовать, он сохраняет свою идентичность: каждое имя сервиса уникально. Сервис может иметь несколько версий, но имя сервиса не зависит от версии. Имена сервисов доступны в конфигурации Istio в виде атрибутов source.service и destination.service.
* Прокси-сервис (Service proxy)<br>
Компонент уровня данных, управляющий трафиком от имени прикладных сервисов.
* Рабочая нагрузка (Workload)<br>
Процесс / двоичный код, развернутый в Istio, обычно представленный такими объектами, как контейнеры, поды или виртуальные машины. Рабочая нагрузка может содержать ноль или более конечных точек; рабочая нагрузка может потреблять ноль или более сервисов. Каждая рабочая нагрузка имеет одно каноническое имя сервиса, связанное с ней, но может также иметь дополнительные имена сервисов.
* Имя рабочей нагрузки (Workload name)<br>
Уникальное имя для рабочей нагрузки, идентифицирующее ее в пределах сервисной сетки. В отличие от имени сервиса и субъекта рабочей нагрузки, имя рабочей нагрузки не является строго контролируемым свойством и не должно использоваться в определениях списков управления доступом (ACL). Имена рабочих нагрузок доступны в конфигурации Istio в виде атрибутов source.name и destination.name.
* Субъект (учетная запись) рабочей нагрузки (Workload principal)<br>
Определяет контролируемые полномочия, под которыми выполняется рабочая нагрузка. Для проверки субъектов рабочих нагрузок в Istio используется аутентификация сервис-сервис. По умолчанию субъекты рабочих нагрузок соответствуют формату SPIFFE ID. Множественные рабочие нагрузки могут совместно использовать одного и того же субъекта, но каждая рабочая нагрузка имеет один субъект. Они доступны в конфигурации Istio в виде атрибутов source.user и destination.user.
* Зона, уровень управления Istio (Zone, Istio control plane)<br>
В набор компонентов, необходимых для работы сервисной сетки Istio, входят Galley, Mixer, Pilot и Citadel.
  - Одна зона представлена одним логическим хранилищем Galley.
  - Все компоненты Mixer и Pilot, подключенные к одному хранилищу Galley, считаются частью одной и той же зоны, независимо от того, где они работают.
  - Одна зона может работать независимо, даже если все другие зоны находятся вне сети или недоступны.
  - Одна зона может содержать только одно окружение.
  - Зоны не используются для идентификации сервисов или рабочих нагрузок. Каждое имя сервиса и каждый субъект рабочей нагрузки принадлежит сервисной сетке в целом, а не отдельной зоне.
  - Каждая зона относится к одной сервисной сетке. Сервисная сетка охватывает одну или несколько зон.
  - В отношении кластеров (например, кластеров Kubernetes) и поддержки мультисред одна зона может иметь несколько экземпляров таких кластеров. Однако пользователям Istio лучше выбрать более простые конфигурации. Запуск компонентов уровня управления в каждом кластере или окружении и ограничение конфигурации зоны единственным кластером являются относительно простой задачей.
