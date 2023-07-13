# Компоненты кластера:

* Etcd
key-value хранилище, в котором хранится вся информация о кластере.
* API-server
* Controller-manager
* Scheduler
* Kubelet
* Kube-proxy

+ Контейнеризация
Система контейнеризации, поддерживающая Container Runtime Interface.
* Сеть
Container Network Interface.
* DNS
Service Discovery (coredns - default).

# ETCD

Работает по протоколу RAFT.
Etcdctl - утилита управления кластером ETCD (в основном используется для проверки здоровья кластера и вохможности делать снапшоты).
Требует быстрых дисков и стабильного широкого линка.

# API-server

* Центральный компонент кластера kubernetes.
* Единственный, кто общается с Etcd.
* Работает по REST API
* Authentication and authorization
Так как он единственный, кто общается с Etcd, работает по TLS и занимается авторизацией и аутентификацией пользователей

**Встроенные подсказки**
Помимо прочего в API server встроена документация по всем объектам, которые мы можем создать в кластере.
Для получения этой документации используется команда **kubectl explain** <type>.<fieldName>[.<fieldName>]
Таким образом, например, мы можем посмотреть описание всех доступных полей в pod'е:
**kubectl explain pod**
Или в spec pod'а:
**kubectl explain pod.spec**
Можно также получить список всех API объектов доступных в кластере:
**kubectl api-resources**
И посмотреть описание при помощи explain любого неизвестного ресурса.
Так что, если у Вас есть kubectl и доступ к кластеру Kubernetes. Вы всегда можете не выходя за пределы консоли получить документацию по любому полю и объекту. Это очень сильно экономит время при работе с кластером.

# Controller-manager

Комплекс различных контроллеров, например:
* Node controller
* Replicaset controller
* Endpoints controller
(Когда создаётся объект (например, сервис) в фоне создаются эндпоинты
* etc
* GarbageCollector (например, удаляет 11-ые replicasets)

Почти для всех абстракций кубернетеса есть свой контроллер.
Общая роль контроллеров - следить за состоянием и созданием новых объектов в рамках своей зоны ответственности.
Controller-manager генерирует описания replicaset'ов и pod'ов из объекта deployment

# Scheduler

Назначает pods на ноды, учитывая:
* QoS
* Affinity / anti-affinity
* Requested resources
* Priority Class

**Affinity**
Affinity - это механизм, который позволяет нам указывать на каких нодах и каким образом поды будут запускаться в кластере.

Affinity:
  NodeAffinity: // позволяет гранулярно управлять процессом запуска подов. 

**Taints** - указывается на ноде и указывает Scheduler'у запрет на размещение на нём всех подов, кроме тех, у кого есть **tolerations**
taints состоит из названия, значения и через двоеточие - эффекта:
**key=value:effect**
**NoSchedule** - запрещает запускать новые поды на узле. Старые при этом продолжают работу.
**NoExecute** - kubelet начинает эвакуировать поды с узла, которые не имеют tolerations против taint'a.

Пример:
**node_taints:**
  - "node-role.kubernetes.io/ingress=:NoExecute"

**ingress_nginx_tolerations:**
  - key: :node-role.kubernetes.io/ingress"
    operator: "Exists"

Tolerations бывает двух видов:

1. Equal – tolerations сработает только при полном совпадении с key, value и effects

    tolerations:
    - key: "key1"
    operator: "Equal"
    value: "value1"
    effect: "NoSchedule"

2. Exist – toleration сработает, если есть совпадение с key и effects

    tolerations:
    - key: "key1"
    operator: "Exists"
    effect: "NoSchedule"

Детали см. оф. документацию: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
Полезный пример:
**kubectl taint nodes node1 key1=value1:NoSchedule**

**NodeSelector**
Самый простой способ управления аллокацией выполняется в два этапа:
1. Сначала надо поставить метки на node командой label:
**kubectl label nodes awesome_node disk=hdd**

Проверить, какие метки уже есть можно через kubectl describe nodes

apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
  nodeSelector:
    disk: hdd

Для deployment nodeSelector передается в шаблон pod-а, как обычно. Не смотря на удобство и прямолинейность подхода – nodeSelector имеет три минуса, один из которых:
nodeSelector применяется в момент аллокации пода и бесполезен, если под уже аллоцирован. Если вам нужно “освободить” ноду – придется поставить на нее метку и затем выкинуть оттуда поды командой **drain.**

2. Вариант был описан выше, взятый из оф. документации:
**kubectl taint nodes nodeName taintKey=taintValue:taintEffect**

taintKey и taintValue – это просто метки, они могут быть произвольными. У taintEffect есть 3 возможных значения:

NoSchedule – новые поды не будут аллоцироваться, однако существующие продолжат свою работу
PreferNoSchedule – новые поды не будут аллоцироваться, если в кластере есть свободное место
NoExecute – все запущенные поды без tolerations должны быть убраны

Более подробные нюансы см. https://prudnitskiy.pro/post/2021-01-15-k8s-pod-distribution/

**Priority Class**
Подам можно выставлять приоритет. Эвакуируются и запускаются в первую очередь поды с более высоким приоритетом.
Если ресурсов не хватает - в первую очередь гасятся поды с более низким приоритетом.

**Limits/requests**
**Pod** - объединяет несколько контейнеров в одну минимальную логическую единицу.
**Limits** - Количество ресурсов, которые POD может использовать.
Это - верхняя граница.
**Requests** - Количество ресурсов, которые **резервируются** для PODа на **ноде**.
Этими ресурсами не делятся с другими PODами на ноде.

**cpu**. 1 cpu = 1000m cpu (мили).
**memory** - это ОЗУ.

**QoS**
Если не задано реквестов и лимитов, поду присваивается класс Best Effort.
Если заданы реквесты и лимиты, но они не равны, присваивается Burstable.
Если равны - Quaranteed.

Для kubernetes наиболее важны поды с Quaranteed, затем приоритет у Burstable.

Scheduler делает watch в Kube-API. Как только видит, что появилась новая запись, начинает работу.
**Поле NodeName как правило заполняется после того, как scheduler выбрал в соответствии с правилами подходящую ноду.**
После чего Kube-API-server записывает это в Etcd.

Самый быстрый способ в случае проблем с controlplane кластера продиагностировать неисправность - это выполнить команду
**kubectl get componentstatuses**

# Kubelet

Работает на каждой ноде кластера.
Единственный компонент, работающий не в Docker (условно можно назвать systemd приложением).

**!!!**
также смотрит в Kube-API и когда видит запрос с созданием нового пода, где NodeName - это принадлежащий ему адрес, начинает действовать:
Отдаёт команды Docker daemon'у и фактически создаёт pods
(отдает Docker'у команды для запуска контейнеров).

Соответственно Kubelet может запускать pod'ы без участия API server
Постоянно мониторит происходящее с подами и транслирует статус в API-server.
Контролирует работу наших подов, следит за их health check'ами.

**Компоненты Kubernetes в порядке их подключения к процессу запуска приложения**

1. kubectl
2. API-server
3. Controller-manager
4. Scheduler
5. Kubelet

# Kube-proxy

Доп. статья:
https://habr.com/ru/companies/ruvds/articles/442646/

Также как и остальные компоненты кластера смотрит в Kube-API server.
Как и Kubelet стоит на всех серверах.
Только один Controller-manager одновременно может быть мастером и выполнять работу в кластере

**Задачи:**
* Управляет сетевыми правилами на нодах
* Фактически реализует Service (ipvs и iptables)
**Kube-proxy реализует абстракцию service!**

Предварительный экскурс:
**Service** - это набор правил (ipvs/iptables)

Следовательно эти правила можно посмотреть (например, команда iptables).
**sudo iptables -t nat -S | grep <service's name>**
--table	-t table	table to manipulate (default: 'filter')
--list-rules -S [chain [rulenum]]

Пример для разбора механики работы сервиса на уровне iptables:

-A KUBE-SERVICES
  -d *.*.*.*/32 // трафик, приходяший на ip-адрес сервиса (тут запечатлён оный ip-адрес).
  -p tcp // по протоколу tcp
  -m comment --cometn "mynamespace/myservice:http cluster
  IP"
  -m tcp --dport 80 // на 80-ый порт
-j KUBE-SVC-UT6F43GJFBEDB03V // нужно отправлять на эту цепочку

Дальнейший пример. Если грепнуть по имени этой цепочки, то мы найдём ещё два правила:

-A KUBE-SVC-UT6A43GJFBEDB03V
  -m comment --comment "mynamespace/myservice:http"
  -m statistic
    --mode random --probability 0.5000000000 // приходящий трафик с вероятностью 50%
-j KUBE-SEP-MMYWB6DZJI4RZ5CQ // будет отправляться в эту цепочку

-A KUBE-SVC-UT6A43GJFBEDB03V
  -m comment --comment "mynamespace/myservice:http"
-j KUBE-SEP-J33LX377GA3DLDWM // всё остальное отправлять в эту цепочку

Таким образом, трафик приходящий по изначальному адресу сервиса *.*.*.*/32 и соответствующий требованиям отправляется в цепочку, состоящую из двух других правил.
Раскрываем дальше:

-A KUBE-SEP-MMYWB6DZJI4RZ5CQ
  -p tcp
  -m comment --comment "mynamespace/myservice:http"
  -m tcp
-j DNAT // приходящий адрес dnat'ится
  --to-destination 10.102.0.93:80 // на данный ip-адрес.

-A KUBE-SEP-J33LX377GA3DLDWM
  -p tcp
  -m comment --comment "mynamespace/myservice:http"
  -m tcp
-j DNAT
  --to-destination 10.102.3.49:80 // или на данный ip-адрес.

Сервис - это своего рода балансировщик трафика на поды, и в контексте iptables он представляет из себя набор правил, которые через mode random probability позволяет балансировать трафик на поды.
**kubectl -n mynamespace get po -o wide**
pod-1   1/1 Running 0   6h  10.102.0.93
pod-2   1/1 Running 0   6h  10.102.3.49

Подводя итог.
Сервис - это некий статический IP-адрес, который был выдан кубернетесом при его создании.
Помимо ip-адреса у сервиса есть DNS имя в kube-dns (example: myservice.mynamespace.svc.cluster.local, "cluster.local" - доменное имя кластера)
DNS имя нужно чтобы иметь возможность обратиться к группе подов, стоящих за этим именем, используя только имя сервиса.
Так, если сделать **nslookup myservice**, то можно попасть в какой-то под.
Сервис - это просто правила iptables для роутинга, которые создаются на серверах. Это - не прокси.

kube-proxy прослушивает мастер-сервер api для изменений в кластере, который включает в себя изменения в сервисах и конечных точках. Когда он получает обновления, использует iptables для сохранения правил netfilter. Когда создается новый сервис и заполняются его конечные точки, kube-proxy получает уведомление и создает необходимые правила. Аналогично он удаляет правила при удалении сервисов. Проверки работоспособности с конечными точками выполняются с помощью kubelet. Это еще один компонент, который выполняется на каждом узле. Когда найдены нездоровые конечные точки, kubelet уведомляет kube-proxy через сервер api, а правила netfilter редактируются, чтобы удалить эту конечную точку, пока она не станет здоровой снова.

# Network

Коротко можно охарактеризовать **цель сети кубернетес** как возможность любого пода с любой ноды обращаться к любому другому поду на любой ноде.
Соответственно коротко **цель сетевого плагина** - раздавать ip-адреса и налаживать взаимодействие между подами и нодами.
Также возможна реализация шифрования между нодами и управлять сетвыми политиками **(Network Policies)** (kalico).

Типичные задачи - попасть из сетевого нэймспейса контейнера в сетевой нэймспейс хоста.
Для этой реализации обычно используется veth-пары, которая одним концом воткнута в интерфейс контейнера, а другим - в bridge ноды.

**Container Network Interface**
Кубернетес занимается оркестрацией контейнеров - то есть организует запуск контейнеров на каком либо сервере-узле кластера.
Проблема состоит в том, что эти сервера могут находится где угодно - в одной локальной сети, в нескольких разных локальных сетях или просто раскиданы по всему интернету...
Способов организации сетевого взаимодействия между узлами кластера и контейнерами, запущенными на этих узлах может быть очень много, и поэтому сам кубернетес сетью не занимается.

Вместо этого придумали стандарт CNI (Container Network Interface), в котором описывается порядок создания сети в контейнерах, принадлежащих одному поду, каким образом назначаются IP адреса и настраивается маршрутизация внутри сетевого пространства пода.

Все контейнеры пода работают в одной network cgroup. Можно сказать, что внутри всех контейнеров находится один и тот же сетевой интерфейс.
Именно поэтому nginx из одного контейнера может слать запросы к php-fpm, запущенному в другом контейнере, на localhost:9000

Программные продукты, реализующие стандарт CNI называют CNI plugin.

Причем кроме задачи назначения IP адресов подам, эти плагины также занимаются задачей построения межузловой сетевой связности в кластере, чтобы обеспечить сетевое взаимодействие между подами, находящимися на разных узлах кластера.

# Interaction scheme

**Kube-API**
1. User создаёт replicaset. **kubectl apply -f replicaset.yaml**
2. Эта информация попадает в **Kube-API server**.
3. Kube-API server записывает полученную информацию в **ETCD**. (API-server - единственный компонент, который взаимодействует с ETCD).
4. После этого отдаёт отчёт юзеру, "replicaset created".

**Controller-Manger**
5. Replicaset Controller-Manager, который подписан на соответствующие ему события (watch (create new replicaset)), видит появление нового объекта replicaset в Kube-API.
6. **create pods** Replicaset Controller-Manager - генерирует описание подов к этому replicaset'у и передаёт это описание в Kube-API.
7. Kube-API записывает эту информацию в ETCD
8. После чего отчитывается Controller-Manager'у, говорит, что он всё записал.
На этой стадии в ETCD хранится replicaset со сгенерированным Controller-Manager'ом описанием подов.

**Scheduler**
9. Scheduler (как и остальные компоненты кластера) постоянно смотрит в API сервер **watch (new pods)** и видит создание новых подов.
10. **bind pods** В соответствии со своими правилами выбирает ноду, на которой можно разместить под. Передаёт эту информацию в API сервер (поле NodeName)
11. Kube-API записывает эту информацию в **ETCD**, обновляя существующий манифест.
12. Отчитывается перед scheduler'ом, что работа сделана.

**Kubelet**
13. Kubelet **watch (bound pods)**. Триггер - появление пода, у которого в поле **NodeName** находится то имя ноды, на которой он работает.
14. Kubelet выполняет **docker run** со всей необходимой для запуска информацией (взаимодействие по API), получая обратную связь от докера.
15. Kubelet транслирует статус пода в API server.
16. Kube-API записывает информацию в ETCD и отдаёт обратную связь kubelet'у.

# IP address scheme
Container Runtime Interface.
Container Network Interface.

1. Pod scheduled on the node.
2. Kubelet calls CRI plugin to create a pod.
3. CRI plugin creates pod sandbox ID and pod network namespace.
4. CRI plugin calls CNI plugin with pod network namespace and pod sandbox ID.
5. CNI plugins configure the pod network
Example: **Flannel CNI plugin**
Flannel fetches **podCIDR** for the node and other cluster network metadata from apiserver and writes it to subnet.env file (/run/flannel/subnet.env)
Flannel CNI plugin configures and calls **Bridge CNI plugin**
Bridge CNI plugin creates the cni0 bridge on the host if it doesn't exist.
It creates a veth device with one end inserted in to the container network namespace and the other end connected to the cni0 bridge.
It then colls the configured IPAM plugin.
host-local IPAM CNI plugin returns the IP address for the container and the gateway (cni0 bridge that the container uses as gateway).
IP address for the container is assigned to the pod and the bridge plugin assigns the gateway IP address to the cni0 bridge.
All the assigned IP addresses are stored locally on the disk under /var/lib/cni/networkd/cni0/
Returns an IP for pod
6. Creates Pause container and adds it to the created network namespace
7. Kubelet calls CRI plugin to fetch the application container image
8. CRI fetches the application container image using containerd.
9. Kubelet calls CRI plugin to start the application container
10. CRI plugin uses containerd to start and configure the application container in pod's cgroup and namespaces.

У каждого сетевого провайдера есть свой агент. Он устанавливается во все узлы Kubernetes и отвечает за сетевую настройку pod'ов. Этот агент идет либо в комплекте с конфигом CNI, либо самостоятельно создает его на узле. Конфиг помогает CRI-плагину установить, какой плагин CNI вызывать.

Местонахождение конфига CNI можно настроить; по умолчанию он лежит в /etc/cni/net.d/<config-file>. Администраторы кластера также отвечают за установку плагинов CNI на каждый узел кластера. Их местонахождение также настраивается; директория по умолчанию — /opt/cni/bin.

**Взаимодействие между CNI-плагинами**
Существуют различные плагины CNI, задача которых — помочь настроить сетевое взаимодействие между контейнерами на хосте.


