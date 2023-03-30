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
**Погуглить что такое Calico Route Reflector**
небольшой лайфхак для того, чтобы работать с Windows-нодами.
Настраиваем дополнительные компоненты для кластера kubernetes: external_cloud_controller, policy_controller, ingress_controller, etc.
В завершении устанавливаем и настраиваем кластерный DNS.
#ВОТ ТУТ ВСЁ РАСПИСАТЬ НАПРОЧЬ ПРЯМО СЮДА ПРИ ПРАКТИКЕ#

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

4 part
