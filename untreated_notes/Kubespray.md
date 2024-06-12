#Kubespray#

kubernetes the hard way - for learning.

Kubespray - подходит как для развёртывания на облачных технологиях, так и на своём железе.
Kubespray - не лучшее решение, поскольку сконструирован на Ansible и при большом количестве серверов сценарий может выполняться до 5-6 часов.

Kubespray позволяет:
1. Установить кластер Kubernetes актуальной версии.
2. Установить готовое контейнерное решение, сетевое решение, кластер Etcd: все те компоненты, которые необходимы для работы кластера Kubernetes.
3. Установить дополнительные компоненты: DNS, ingress-control, cert-manager'ы, интеграцию с сетевыми системами хранения данных, но на боевых средах лучше использовать установку дополнительных компонентов другими средствами.
Поскольку если вы что-то установите дополнительно Kubespray'ем, то и обновлять это нужно будет через Kubespray, а значит - запускать его весь и прогонять все сценарии.
4. Добавлять новые ноды в кластер.
5. Обновлять версию кластера.

Документация Kubespray'a:
https://github.com/kubernetes-sigs/kubespray

Копируем директорию с гита на первый мастер.
Переходим в директорию **kubespray/**
Основной файл c playbook'ом для Kubespray называется **cluster.yaml**
В этом файле находится список тех ролей, которые Kubespray будет последовательно применять на наши ноды для установки кластера.

Проверяем версию Ansible.
Если используем прокси хост, проверяем настройки для прокси-хоста.
Проводим первичную настройку операционной системы.
Собираем факты с наших нод.
Подготовительные действия по установке кластера kubernetes, подключаем и устанавливаем container-engine.
Устанавливаем кластер ETCD (2 роли, работает либо одна, либо другая).
Устанавливаем, настраиваем и подготавливаем для деплоя кубернетесовские ноды.
Устанавливаем control-plane компоненты кластера: kube api server, controller manager scheduler, генерировать для них сертификаты, генерировать их манифесты, конфигурации; генерировать клиентские сертификаты и доступы к кластеру.
Настраиваем с помощью утилиты kubeadm сами ноды кластера kubernetes и вводить их в кластер, подключать сетевой плагин для нашего кластера kubernetes.
Настраиваем дополнительные компоненты для кластера kubernetes: external_cloud_controller, policy_controller, ingress_controller, etc.
В завершении устанавливаем и настраиваем кластерный DNS.

Сперва обновляем pip, если нужно:
pip3 install --upgrade pip
Из директории Kubespray необходимо обновить requirements.txt:
pip3 install -r requirements-2.11.txt

В директории inventory/sample уже есть подготовленный образец инвентаря, поэтому мы копируем её:
cp -r /inventory/sample /inventory/your_inventory

Для практики:
[all]
master-1
master-2
master-3
ingress-1
node-1
node-2

[control_plane]
master-1
master-2
master-3

[etcd]
master-1
master-2
master-3

[kube_node]
node-1
node-2
ingress-1

[kube_ingress]
ingress-1

[k8s_cluster:children]
kube_control_plane
kube_node

kube_pods_subnet не должны совпадать с kube_service_addresse

В Ansible есть встроенная группа all. В ней находятся все хосты, описанные в инвентаре.
Указать переменные для группы можно двумя способами:
1. В файле с именем группы,
например, для группы control_plane - это файл по пути **group_vars/control_plane.yml**
2. Если много переменных, то можно разложить их на несколько файлов и положить эти файлы в директорию с именем группы:
**group_vars/control_plane/load.yml**

Пройдёмся по некоторым переменным из **group_vars/all**.
**group_vars/all/all.yml**
kubelet load modules: true # Параметр, позволяющий kubelet подгружать необходимые ему модули ядра.
kubeadm enabled: false # Ставим без kubeadm
kube read only port: 10255 # Параметр, включающий порт откуда можно получать метрики узла без авторизации. Поднимается на сером адресе внутри кластера. Нужен для мониторинга.

**group_vars/all/docker.yml**
docker_storage_options: -s overlay2 # Запустить docker с файловым драйвером overlay2

**group_vars/all/download.yml**
download_run_once: true # Оптимизация загрузки необходимых образов и файлов. Загрузка из интернета на один сервер, копирование на все узлы нашего кластера.

**group_vars/etcd.yml**
etcd_snapshot_count: "5000" # Количество записей в журнале операции, которые хранятся в памяти. Уменьшение необходимо для экономии памяти ETCD в **тестовом** кластере.
etcd_memory limit: 0 # Отключаем ограничение по памяти

**Настройки серверов в группе k8s-cluster**
**group_vars/k8s-cluster/k8s-cluster.yml**
kube_version: v1.18.3 - версия кубернетес.
kube_eidc_auth: false
kube_basic_auth: false - два вида аутентификации. Оставляем аутентификацию по токену.
kube_network_plugin: flannel - CNI
kube_service_addresses: 10.100.0.0./16 - адреса из этой сети будут назначаться на сервисы типа cluster_ip.
kube_pods_subnet: 10.0.0.0/16 - адреса из этой сети будут назначаться подам в нашем кластере.
**kube_pods_subnet не должны совпадать с kube_service_addresse**
kube_apiserver_insecure_port: 0 - отключаем беспарольный доступ к api server.
kube_proxy_mode: iptables - режим работы прокси (iptables, ipvs)
kube_proxy_mode - ipvs обеспечивает более высокую пропускную способность и более быструю пересылку, чем iptables.

<details>
    <summary>Ipvs vs. iptables</summary>
IPvs (IP Virtual Server) реализует балансировку нагрузки на грузоподъемность, обычно называемую LAN 4 LAN Exchange, является частью ядра Linux.
IPvs работает на хосте и действует как балансировщик нагрузки перед кластером реального сервера. IPvs могут направлять запросы на службы на основе TCP и UDP на реальных серверах и отображать службу реального сервера в качестве виртуального обслуживания на одном IP-адресе.

Когда 20 лет назад iptables начал свое существование, заменив предшественника ipchains, функциональность брандмауэра была прописана очень просто:
* Защита локальных приложений от получения нежелательного сетевого трафика (цепочка INPUT)
* Защита локальных приложений от отправки нежелательного сетевого трафика (цепочка OUTPUT)
* Фильтрация сетевого трафика, пересылаемого/маршрутизируемого системой Linux (цепочка FORWARD).
Это была эпоха, когда iptables был первоначально разработан и спроектирован. Стандартной практикой применения списков контроля доступа (ACL), как это реализовано в iptables, было использование последовательного списка правил, т.е. каждый полученный или переданный пакет сопоставляется со списком правил, один за другим.
Однако у линейной обработки есть очевидный крупный недостаток: издержки на фильтрацию пакета могут увеличиваться линейно с количеством добавляемых правил.

Сообщество быстро определило самое узкое место: длинные списки правил, отклоняющих или разрешающих отдельные комбинации IP-адресов и портов. Это привело к появлению ipset. ipset позволяет сжать список правил, соответствующих IP-адресам и/или комбинациям портов, в хэш-таблицу, уменьшая общее количество правил iptables. С тех пор такое решение служит обходным путем.
К сожалению, ipset не является ответом на все проблемы. Ярким примером является kube-proxy, компонент Kubernetes, который использует правила iptables и -j DNAT для обеспечения балансировки нагрузки на сервисы. Он устанавливает несколько правил iptables для каждого бэкенда, к которому обращается служба. Для каждого сервиса, добавляемого в Kubernetes, список правил iptables, которые необходимо пройти, растет экспоненциально.
kubernetes.io/docs/concepts/services-networking/service
</details>

kubeconfig_localhost: true - копирование настроек для доступа под администратором
kubectl_localhost: true - копирование утилиты kubectl на тот сервер, где мы запускаем ansible.
kubelet_authentication_token_webhook: true
kubelet_authorization_mode_webhook: true - включение доступа к kubelet по токену.

**group_vars/k8s-cluster/k8s-net-flannel.yml**
flannel_backend_type: "host-gw" - режим host gateway
flannel_interface_reqexp - указываем flannel на каком именно интерфейсе у нас прописан маршрут.

**group_vars/k8s-cluster/addons.yml** - только для учебных целей
ingress_nginx_enabled: true - включить установку контроллера
ingress_nginx_host_network: true - указываем, что нужно использовать сеть типа host network. (Внутрь контейнера прокидывается сетевой namespace узла)
ingress_nginx_configmap: - настройки ingress-controller
  server-tokens: "False" - скрыть версию.
  proxy-body-size: "2048M" - принимаем запросы до 2 Мб.
  proxy-buffer-size: "16k" - настраиваем буффер приёма в 16 килобайт.
  worker-shutdown-timeout: "180" - сколько секунд ждать завершения работы worker'ов при reload config.

ingress_nginx_nodeselector:
  node-role.kubernetes.io/ingress: "" - запускаться только на узлах с меткой *node-role,kubernetes.io/ingress*
метка ставится на узлах. Пример:
**group_vars/kube-ingress.yml**
node_labels:
  node-role.kubernetes.io/ingress: ""

**taints vs. tolerations:**
taints состоит из названия и значения, где через двоеточие указывается эффект. Пример:
node_taints:
  - "node-role.kubernetes.io/ingress-:NoSchedule" - запретить запуск нодов на узле. При этом старые ноды, работавшие на узле до taint'a продолжают на нём работать.
**NoExecute - kubelet начинает эвакуировать поды, не имеющие tolerations.**

**Пример прописывания tolerations к taints в подах:**
**group_vars/kube-ingress.yml**
ingress_nginx_tolerations:
  - key: "node-role.kubernetes.io/ingress"
    operator: "Exists"

Для практики необходимо:
1. Задать имя кластера в **group_vars/k8s-cluster.yml** (cluster_name)
2. Уточнить настройки сетевого плагина.

**Static pods**:
Поды, запущенные и управляемые kubelet'ом называются статическими.
(Обычные pods создаются в ответ на команды kube-apiserver с помощью kubelet)
По умолчанию статические поды можно посмотреть в переменной **staticPodPath**.
Пример:
*staticPodPath: /etc/kubernetes/manifests*
Если поместить в эту директорию манифест пода, то kubelet создаст его и appends the node name to the pod name.

Поды kube-apiserver и других компонентов control-plane создаются kubelet как статические, потому что во время установки YAML-файлы этих компонентов создаются в lbhtrnjhbb /etc/kubernetes/manifests.
**Example:**
root:/home/ubuntu/pods# ls -l /etc/kubernetes/manifests/
total 16
-rw------- 1 root root 2209 Mar 29 14:49 etcd.yaml
-rw------- 1 root root 3854 Mar 29 14:49 kube-apiserver.yaml
-rw------- 1 root root 3251 Mar 29 14:49 kube-controller-manager.yaml
-rw------- 1 root root 1435 Mar 29 14:49 kube-scheduler.yaml

#Обновление кластера
При обновлении кластера Kubespray:
загружает новые образы на все узлы параллельно,
обновляет узлы в группе kube-master последовательно,
обновляет docker или другую, используемую среду контейнеризации.

**Последовательность действий**:
Изучаем документацию (change log) - описываются все изменения, которые могут сломать кластер.
Устанавливаем тестовый кластер.
Обновляем его.
Деплоим приложения, проверяем работу.
Планируем время обновления.
Делаем backup'ы.
Обновляем прод по одной ноде.
После каждой ноды проверяем работоспособность.

Что обновляем: порядок
etcd database
Control plane: API, controller-manager, scheduler + kubelet
kubelet on worker node
*Системный софт:*
kube-proxy
CNI
coredns, nodelocaldns
ingress-nginx-controller
certificate - при необходимости продлеваем сертификаты

**ИЗУЧИТЬ ВСЕ НЕПОНЯТНЫЕ СЛОВА**

Для обновления кластера в Kubespray есть специальный файл: **upgrade-cluster.yml**
Основное отличие - tasks по обновлению выполняются последовательно, а не параллельно. (переменная **serial: 1**)
Варианты на рабочих узлах:
**serial: "{{ serial | default('20%') }}"** - одновременно будет обновляться 20 процентов от рабочих узлов в кластере.

Также при обновлении через Kubespray происходит обновление docker'a:
kubespray/roles/container-engine/docker/vars/ - указаны версии для **docker**'a. Можно обновить вручную в соответствии с версией kubernetes, на которую мы переходим. Тогда kubespray сверит версии и не будет обновлять его. Это уменьшит риск сломать что-либо при автоматическом обновлении.

#StatefulSet
Позволяет запускать группу подов (как Deployment)
* Гарантирует их уникальность
* Гарантирует их последовательность
PVC template
* При увеличении числа подов StatefulSet будет увеличиваться число PVC
* При удалении не удаляет PVC (при scale, etc)
* PVC нужно удалять вручную
Поэтому используется для запуска приложений с **сохранением состояния**.
Например:
* Rabbit
* Redis
* Kafka
* ...

**Affinity**
Affinity - это механизм, который позволяет нам указывать на каких нодах и каким образом поды будут запускаться в кластере Kubernetes
Пример - когда некоторые поды нельзя запускать на одних и тех же нодах кластера.
Ранее мы реализовывали nodeSelector - указывая на каких нодах следует запускать поды с определёнными метками.

nodeAffinity - похожа на nodeSelector, за исключением более гранулярной возможности (как и где) запускать поды.
ignoredDuringExecution - если метки на нодах изменятся в тот момент, когда поды уже расположены на этих нодах, с подами ничего происходить не будет.
(игнорируем, пока идёт процесс выполнения).
requiredDuringScheduling - жёсткое ограничение - если под не соответствует требованиям, он всегда будет в состоянии pending.
preferredDuringScheduling - мягкое ограничение - если под не соответствует требованиям, kubernetes запустит под на любой другой подходящей ноде.
podAntiAffinity: - поды с определённой меткой нельзя запускать вместе на одной ноде.
  preferredDuringSchedulingIgnoredDuringExecution: - стараться не запускать на одной ноде
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
            - key: app
              operator: In
              values:
                - rabbitmq
        topologyKey: kubernetes.io/hostname
podAffinity: - всегда запускать или стараться запускать поды с определёнными метками вместе.

#Job
Job - это абстракция для выполнения задач.
Не предназначен для постоянных задач типа демонов
* Создаёт под для выполнения задачи (если вернулся не 0, то)
* Перезапускает поды до успешного выполнения задачи
* или истечения таймаутов
activeDeadLineSeconds - сколько общего времени есть у job'a до завершения. В этот таймер включены все повторы и перезапуски всех подов.
backoffLimit - сколько перезапусков может быть у job'a. Соответственно после 3 перезапусков job будет помечен как неуспешный.
ttlSecondsAfterFinished - контролирует как долго ваш job после завершения будет жить в кластере. Затем Garbage Collector почистит его.

Параметр restartPolicy в pod'е контролирует в каких случаях нужно перезапускать pod и нужно ли в принципе.

#Cronjob

Создаёт Job по расписанию
Важные параметры:
* startingDeadlineSeconds - какое время есть у Job'a на то, чтобы запуститься, в случае если расписание запуска по какой-то причине было пропущено.
* concurrencyPolicy - (always -  по умолчанию) что делать, если наступило время выполнения нового job'a в то время как старый ещё не был завершён.
Вариант по умолчанию - запустить рядом новый. Другие варианты - Never, Replace.
* successfulJobsHistoryLimit - сколько старых успешных Job'ов в успешном состоянии завершённых можно хранить.
* failedJobsHistoryLimit - сколько старых неудачно завершённых job'ов можно хранить.

#RBAC

Role Base Access Control
Существует 5 типов объектов, относящихся к этой категории:

* Role
* RoleBinding
* ClusterRole
* ClusterRoleBinding
* ServiceAccount

**Роль** представляет собой набор прав, которые есть у пользователя в кластере.
Роль не говорит о том, у кого именно эти права есть, она создаёт набор прав.

Пример команд для кластера:
kubectl edit role -n ingress-nginx nginx-ingress 
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  annotations:
    meta.helm.sh/release-name: nging-ingress
    meta.helm.sh/release-namespace: ingress-nginx
  creationTimestamp: "2022-09-15T11:41:54Z"
  labels:
    app: nginx-ingress
    app.kubernetes.io/managed-by: Helm
    chart: nginx-ingress-1.24.6
    heritage: Helm
    release: nginx-ingress
  name: nginx-ingress
  namespace: ingress-nginx
  resourceVersion: "856"
  uid: d12ddb8b-11d4-4b50-b307-42c66c5e2db7
rules:
- apiGroups:
  - "" // Если пустая, значит apiGroups v1
  resources:
  - namespaces
  verbs:
  - get
- apiGroupts:
  - ""
  resources:
  - configmaps
  - pods
  - secrets
  - endpoints
  verbs:
  - get
  - list
  - watch

Это - некий набор разрешений, который потом уже можно будет навесить на какого-нибудь пользователя или сущность внутри kubernetes.

**RoleBinding** - объект, который связывает роли и конкретных пользователей или группы пользователей.

roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: nginx-ingress
subjects: # Кому мы выдаём права
- kind: ServiceAccount # Некая сервисная учётная запись внутри кубернетес
  name: nginx-ingress
  namespace: ingress-nginx
- kind: User
  name: jane # "name" is case sensitive
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: developer # for example organization in user certificate
  apiGroup: rbac.authorization.k8s.io

В самом кубернетес таких объектов как user, group - нет. Для их реализации необходимо устанавливать внешние механизмы аутентификации для кластера.

ServiceAccount: некая учётная запись, нужная для работы внутри кластера kubernetes.
При создании в кластере ServiceAccount ServiceAccountController автоматически создаст нам secret. Обычно ServiceAccount'ы нужны для авторизации тех приложений, которые работают внутри кластера kubernetes и обращаются к api kubernetes для каких-то взаимодействий с ним.
При создании ServiceAccount'а в кластере автоматически создается секрет с токеном для доступа к Kube API серверу.

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: user

# DNS в кластере kubernetes
Публикация приложения возможна двумя способами:
* Service: L3 OSI, NAT, kube-proxy
* Ingress: L7 OSI, HTTP и HTTPS, nginx, envoy, traefik, haproxy

**Kubernetes Service**:
* ClusterIP
* NodePort
* LoadBalancer
* ExternalName
* ExternallPs

# ClusterIP
ClusterIP используется по умолчанию, и это означает, что «сервису будет назначен IP-адрес, доступный из любого пода в кластере». Тип сервиса можно узнать, запустив **kubectl describe services** с именем сервиса.

Сервис типа **ClusterIP** - один из самых распространённых сервисов, с помощью которого строится взаимодействие внутри кластера.
Он работает только внутри кластера и распределяет запросы на поды только от пользователей, которые находятся внутри кластера.
Используя его мы можем настроить взаимодействие одной группы подов с другой группой подов.

Пример манифестации:
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector: // здесь указывается значение labels тех подов, куда нужно отправлять трафик.
    app: my-app
  type: ClusterIP
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP

Два правила без которых сервис работать не будет:
1. Совпадение selector and label
2. Необходимость, чтобы под и сервис работали в одном нэймспейсе.

Сервис ClusterIP больше нужен для настройки взаимодействия внутри кластера и не подходит для удобной публикации приложения наружу из кластера.

# NodePort

Позволяет публиковать приложение наружу.
На каждой ноде кластера открывает порт со значением 30 тыс.+
Причём, если обратиться на внешний IP-адрес нашей ноды и этот порт, то мы попадём в искомый под и приложение.

Пример манифестации:
apiVersion: v1
kind: Service
metadata:
  name: my-service-np
spec:
  selector:
    app: my-app
  type: NodePort
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP

В действительности NodePort используется если есть внешний балансировщик, который стоит за кластером и может отправлять трафик на бэкенд (ip-адреса и порты наших нод).
С сервисом типа NodePort можно публиковать приложения, работающие не на протоколе http. Например, TCP, rabbitmq, бд,

# LoadBalancer

Этот сервис хорошо подходит для публикации приложений, но он работает только в облачных провайдерах.
Механика работы следующая: снаружи кластера есть контроллер, который смотрит в api-server и контролирует создание новых сервисов типа LoadBalancer'a.
И когда такой сервис создаётся, этот контролер создаёт внешний балансировщик (например, Elastic Load Balancer), который уже в свою очередь отправляет трафик внутрь кластера на данный сервис в наше приложение.
Если такого контроллера нет, то Load Balancer будет висеть в состоянии pending.
Также в Load Balancer есть возможность задавать статический ip-адрес (поле LoadBalancerIP). На этом ip-адрес балансировщик будет принимать запросы и отправлять их в наше приложение.

Пример манифестации:
apiVersion: v1
kind: Service
metadata:
  name: my-service-lb
spec:
  selector:
    app: my-app
  type: LoadBalancer
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP

# ExternalName

Данный тип сервиса используется для организации исходящего трафика.
К задаче приема запросов из интернета и передачи в наше приложение этот тип сервиса отношения не имеет.

Суть работы сервиса ExternalName - делать отсылку на внешний ресурс.

Пример манифестации:
apiVersion: v1
kind: Service
metadata:
  name: my-service // в данном примере при обращении на имя my-service мы попадём на адрес, указанный в поле exsternalName
spec:
  type: ExternalName
  externalName: example.com // сюда

Тем самым мы можем перенаправлять запросы на внешний ресурс, используя данный тип сервиса.

# ExternalIPs

Похож на NodePort за тем исключением, что NodePort открывает порты на нодах, а ExternalIPs при создании генерирует правила трансляции с ip-адреса в ваше приложение.
После создания этого сервиса, на всех серверах кластера будут созданы правила трансляции (iptables или ipvs), которые трафик, приходящий на данный ip-адрес (поле externalIPs), будут отправлять в ваше приложение.

Пример манифестации:
apiVersion: v1
kind: Service
metadata:
  name: myservice
spec:
  selector:
    app: my-app
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  externalIPs:
  - 80.11.12.10

Используется в случае если между нодами есть связь по протоколу VRRP (работает keep-alive или что-то подобное). Тогда ip-адрес можно привязать к ip в externalIPs и быть уверенными, что на всех серверах кластера, вне зависимости от того, где они находятся, правило трансляции есть и соблюдается.

# Небольшой итог по сервисам

Использовать сервисы для публикации приложений имеет смысл, если приложение использует бинарный протокол типа gRPC или AMQP, а также для передачи трафика в ingress controller, если хостер или структура построения сети не позволяет установить на узел реальный ip адрес и запускать ingress controller в режиме hostNetwork: true. Например, если используется managed кластер, предоставляемый облачным провайдером.

Если ваше приложение использует протокол HTTP, то в данном случае для доставки трафика из интернета стоит использовать Ingress Controller.

# Ingress

Трафик приходит на Ingress Controller, а оттуда уже распределяется по сервисам/приложениям, в зависимости от установленных на нём правил.
Чисто технически Ingress Controller, если мы хотим обслуживать трафик извне, нужно выставить наружу.
Обычно это делается с использованием директив Host Port.
То есть несмотря на то, что Ingress Controller - это приложение, поднятое в контейнере, его порт нужно публиковать наружу.
Тогда обращаясь по 80 порту ip-адреса хоста мы попадаем в Ingress Controller и как следствие - в наш кластер и приложение.

**Ingress** - манифест в котором описаны правила, позволяющие обрабатывать внешний трафик.
Манифест, описывающий правила маршрутизации HTTP-запросов.
(С каких доменов, на какие эндпоинты и какие сервисы)
**Ingress Controller** - приложение, обрабатывающее трафик или специальная проксирующая программа, которая направляет запросы из интернета в приложения.

Пример:
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: my-ingress
  annotations: # В каждом объекте и манифесте может быть задана аннотация
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS" # В рамках этой аннотации мы указываем, что наш backend принимает трафик по protocol HTTPS
    # Таким образом мы можем задавать дополнительные настройки в аннотациях, их перечень есть в официальной документации.
spec:
  rules:
  - host: foo.mydomain.com
    http:
      paths:
      - backend:
          serviceName: foo
          servicePort: 8080
  - host: mydomain.com
    http:
      paths:
      - path: /bar/
        backend:
          serviceName: bar
          servicePort: 8080

**Создаём секрет с сертификатом**
kubectl create secret tls ${CERT_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}

apiVersion: v1
data:
  tls.crt: base64 encoded cert
  tls.key: base64 encoded key
kind: Secret
metadata:
  name: secret-tls
  namespace: default
type: kubernetes.io/tls

Имея этот сертификат, мы можем указать его в ingress:
**Указываем сертификат в Ingress.**
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  tls:
  - hosts:
    - sslfoo.com
    secretName: secret-tls
    
# DNS in cluster kubernetes

DNS в кластере kubernetes выполняет роль service discovery, то есть мы можем обращаться по DNS имени сервиса и попадать в группу подов.
В кластере DNS как правило представлен CoreDNS, запущенный на 53-ем порту и мы обращаемся к нему, получая резолв наших запросов.
Клиентский под, в котором работает наше приложение, делает DNS-запрос.
DNS-запрос, в зависимости от устройства кластера, может попасть сперва в кэширующий локальный сервер (Local DNS Cache),
либо, если его нет, запрос идёт сразу на основной сервер CoreDNS.

В первом случае, если запись есть в кэше, то она сразу отдаётся приложению.
Если записи нет, то Local DNS Cache запросит данные у Core DNS сервера, запишет данные себе в кэш и ответит в клиентский под.

Local DNS Cache при этом общается с Core DNS через IP tables CoreDNS ClusterIP.

В подах в файле /etc/resolv.conf содержится перенаправление адресов:
root@lic-integrator-5bc4884df9-wqxxr:/etc# cat resolv.conf
search integrators.svc.fsrap.ru svc.fsrap.ru fsrap.ru 
nameserver 172.96.0.10 // указание ip-адреса Node Local DNS, если он есть
options ndots:5 // эта настройка говорит, что если в имени файла содержится меньше 5 точек, то это внутренний запрос и его нужно прогонять через search, выискивая адресат внутри кластера.

Эти настройки содержатся на ноде в Kubelet:
cat /etc/kubernetes/kubelet.env | grep dns

-cluster-dns=172.96.9.10 -cluster-domain=fsrap.ru

Для того, чтобы отключить эти перенаправления и отправлять внешние запросы вовне, нужно подправить ConfigMap CoreDNS, включить autoPath Kubernetes,
изменить параметр pod на verifier.
**Загуглить pods verivier kubernetes autopath coredns**
