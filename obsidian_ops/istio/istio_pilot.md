# Pilot

Pilot отвечает за программирование уровня данных, входных и выходных шлюзов и прокси в сетке Istio. Pilot моделирует среду развёртывания, комбинируя конфигурацию Istio от Galley и информацию о сервисах из реестра, такого как Kubernetes API Server или Consul.<br>
Pilot использует эту модель для создания конфигурации уровня данных и передаёт созданную конфигурацию в парк подключённых к нему прокси.<br>

Pilot использует три основных **источника конфигурации**:<br>
* **Конфигурация сетки**<br>
Набор глобальных конфигураций для сервисной сетки.
* **Конфигурация сети**<br>
Конфигурации ServiceEntry, DestinationRule, VirtualService, Gateway и прокси.
* **Механизм обнаружения сервисов**<br>
Местоположение и метаданные из реестров о каталоге сервисов, размещённых на одной или нескольких нижележащих платформах.

## Конфигурация сетки
**Конфигурация сетки** - это статический набор глобальных конфигураций для её установки.<br>
Конфигурация сетки определяется по трём объектам:<br>
* **MeshConfig** описывает настройку взаимодействий между компонентами Istio, местонахождение источников конфигурации и т. д.
* **ProxyConfig**<br>
**ProxyConfig** описывает параметры инициализации Envoy: местоположение начальной конфигурации, привязки портов и т. д.
* **MeshNetworks**<br>
**MeshNetworks** описывает набор сетей, охватываемых сервисной сеткой, с адресами входных шлюзов каждой сети.

**MeshConfig** в основном используется для настройки следующих параметров: включена ли политика и/или телеметрия, откуда загружать конфигурацию, и настройки балансировки нагрузки в зависимости от местоположения. MeshConfig содержит следующий исчёрпывающий набор настроек:<br>
* Использование Mixer:<br>
  - адреса серверов политики и телеметрии;
  - включена ли проверка политик во время выполнения,
  - отказывать ли в открытии или закрытии, если Mixer Policy недоступен или возвращает ошибку;
  - проверять ли политику на стороне клиента?
* настройка прокси на приём:<br>
  - порты приёма трафика (т. е. порты, куда трафик перенаправляется с помощью iptables) и запросов HTTP PROXY;
  - настройки keep-alive и тайм-аута TCP-соединения;
  - формат журнала доступа, имя файла и способ кодирования (JSON или текст);
  - разрешить ли весь исходящий трафик или только из сервисов, известных Pilot?
  - где принимать секреты от Citadel (SDS API) и как настроить проверку идентичности (в среде с токенами на локальных машинах)?
* поддерживать ли ресурсы Kubernetes Ingress?
* набор источников конфигурации для всех компонентов Istio (например, локальная файловая система или Galley) и как с ними взаимодействовать (адреса, использовать ли TLS, какие секреты и т. д.)

**ProxyConfig** в основном используется для создания пользовательской конфигурации загрузки для Envoy.<br>
ProxyConfig определяет следующие аспекты:
* Местонахождение файла с загрузочной конфигурацией Envoy, а также местонахождение самого двоичного файла Envoy;
* Имя сервиса, к которому нужен sidecar Envoy;
* Настройки выключения (порядок остановки соединения и горячего перезапуска);
* Местонахождение сервера xDS Envoy (Pilot) и способы связи с ним;
* Настройки тайм-аута соединения;
* Какие порты прокси должны использоваться для администрирования и получения статистики?
* Параллелизм Envoy (число рабочих потоков);
* Как Envoy привязывает сокет для перехвата трафика (через iptables REDIRECT или TPROXY)?
* Местонахождение сборщика телеметрии (т. е. куда отправлять данные телеметрии).

**MeshNetworks** определяет набор именованных сетей, способ передачи трафика в эту сеть и местоположение этой сети.<br>
Каждая сеть представляет собой либо диапазон бесклассовой междоменной маршрутизации (Classless Inter-Domain Routing, CIDR), либо набор конечных точек, возвращаемый реестром сервисов (например, Kubernetes API Server).<br>
Объект ServiceEntry, используемый для определения сервисов в Istio, имеет набор конечных точек.<br>
У каждой конечной точки может быть метка сети, чтобы ServiceEntry мог описать сервис, развёрнутый в нескольких сетях (или кластерах).<br>
Большинство значений в MeshConfig не могут обновляться динамически, и для вступления их в силу необходимо перезапустить **уровень управления**.<br>
Аналогичным образом обновление значений в ProxyConfig вступает в силу только после повторного развёртывания Envoy.<br>
MeshNetworks можно динамически обновлять во время работы без перезапуска каких-либо компонентов уровня управления.<br>

## Сетевая конфигурация

ServiceEntry является центральным элементом сетевых API Istio.<br>
**ServiceEntry** определяет сервис по именам - как набор имён хостов, используемых клиентами для вызова сервиса.<br>
Правила **DestinationRule** управляют взаимодействиями клиентов с сервисом, а именно: стратегии балансировки нагрузки, обнаружения отклонений, обрыва цепи и организации пула используемых соединений; настройки TLS и т. д.<br>
**VirtualService** задают конфигурацию потока трафика к сервису:
* маршрутизация L7 и L4,
* формирование трафика,
* повторные попытки,
* тайм-ауты и т. д.
**Gateways** определяют доступность сервисов из-за пределов сетки:
* какие имена каким сервисам соответствуют,
* как обслуживать сертификаты для этих хостов и т. д.
**Прокси** управляют доступностью сервисов внутри сетки: какие сервисы доступны и каким клиентам.

## Обслуживание конфигурации
Из трёх источников конфигурации - сети, сетки и обнаружения сервисов - Pilot создаёт модель окружения и развёртывания.<br>
Асинхронно, по мере развёртывания в кластере, прокси подключаются к Pilot.<br>
Pilot группирует прокси на основе их меток и подключённых к ним сервисов.<br>
Используя эту модель, Pilot генерирует ответы Discovery Service (xDS) для каждой группы подключённых прокси.<br>
Pilot посылает текущее состояние окружения и конфигурацию.<br>
Когда изменяется конфигурация xDS, Pilot определяет, какие прокси эти изменения затрагивают, и передаёт им обновлённую конфигурацию.<br>

Как сетевая конфигурация Istio проявляется в xDS (в высокоуровневых понятиях).<br>
Конфигурацию прокси (Envoy) можно разделить на две основные группы:
* приёмники и маршруты;
* кластеры и конечные точки.
Приёмники настраивают набор фильтров (например, поддержка HTTP в Envoy определяется фильтром HTTP) и связь между этими фильтрами и портами.<br>
Есть два типа приёмников:<br>
**физический** - тот, к кому Envoy привязывается через указанный порт, и<br>
**виртуальный** - тот, кто получает трафик от физических приёмников.<br>
**Маршруты** сопутствуют приёмникам и определяют, как приёмники направляют трафик в определённый кластер (например, сопоставляя HTTP-путь или посредством **Service Name Indication (SNI)**.<br>
**Кластер** - это группа эндпоинтов с информацией о том, как с ними связаться (настройки TLS, стратегия балансировки нагрузки, настройки пула соединений и т. д.)<br>
**Кластер аналогичен "сервису"** (например, один сервис Kubernetes может объявляться как один кластер).<br>
Наконец, **эндпоинтами** являются отдельные сетевые узлы (IP-адреса или доменные имена), куда Envoy направит трафик.<br>

**Замечание про "x"**<br>
Envoy API мы называем xDS API, так как каждый конфигурационный примитив (приёмник, маршрут, кластер, конечная точка) имеют свой собственный Discovery Service, названный в его честь.<br>
Каждый Discovery Service позволяет обновлять свой ресурс.<br>
Вместо того, чтобы ссылаться по отдельности на LDS (listener), RDS (route?), CDS (cluster), EDS (endpoint), мы используем обобщённое название **xDS API.**<br>

Сетевая конфигурация Istio почти напрямую отображается в Envoy API:
* шлюзы настраивают физические приёмники;
* VirtualService конфигурируют виртуальные приёмники (совпадения имён хостов кодируются как отдельные приёмники, а обработка протокола конфигурируется приёмниками с помощью специальных фильтров), так и маршруты (условия соответствия HTTPS/TLS, конфигурация повторной передачи и тайм-аутов и т. д.);
* ServiceEntry создают кластеры и заполняют их конечные точки;
* DestinationRule конфигурируют взаимодействие с кластерами (секреты, стратегия балансировки нагрузки, разрыв связи, объединение соединений в пулы и т. д.) и создают новые кластеры, когда они используются для определения подмножеств.
Последним элементом сетевой конфигурации Istio являются настройки прокси для сервисов. Они не относятся напрямую к примитиву Envoy: Istio использует эти настройки для выбора конфигурации, посылаемой каждой группе Envoy.

## Отладка и устранение неисправностей в Pilot
Команды:
```
istioctl proxy-config
istioctl proxy-status
# k8s-зависимы (древний год)
# istio proxy-config использует kubectl exec для получения данных с удалённой машины
```
Подключение к указанному поду и запрос административного интерфейса прокси для получения текущей конфигурации прокси.
```
istioctl proxy-config <bootstrap | listener | route | cluster> <kubernetes pod>
```

### Listeners
Определения ресурсов Gateway и VirtualService описывают listeners в Envoy.<br>
Gateway предоставляет физические приёмники (привязанные к порту в сети)<br>
VirtualService - виртуальные приёмники (не привязанные к порту, но получающие трафик от физических приёмников).<br>
Проверка манифестов:
```
istioctl proxy-config listener podname -o json -n namespace
istioctl proxy-config route podname -o json -n namespace # VirtualService
```
Если использовать istioctl для просмотра кластеров, можно заметить, что Istio генерирует кластер для каждого сервиса и порта в сетке:
```
istioctl proxy-config cluster podname -o json
```
Другим инструментом, используемым для создания и обновления кластеров в Istio является DestinationRule.<br>
(Обновление настроек балансировки нагрузки и TLS влияет на конфигурацию внутри самого кластера).