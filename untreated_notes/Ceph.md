Ceph - ПО, которое создаёт распределённое, отказоустойчивое хранилище объектов.

RBD - блочное устройство с поддержкой тонкого роста и снапшотами. ???? Виртуальный винчестер like.
Возможность быстрой миграции виртуальной машины между железными узлами. - RBD. WHY??????
CephFS - распределённая POSIX-совместимая файловая система.
RADOS Gateway - S3- и Swift-совместимый RESTful интерфейс.

Демоны Ceph.
MON - демон монитора,
модуль управления,
точка подключения клиентов.
OSD - демон хранилища.
MDS - сервер метаданных для CephFS.
MGR - демон менеджер,
метрики и
мониторинга.

**Устройство хранилища**
Pool. Имеет фактор репликации.
Состоит из placement group.
Placement group. Группа в которой хранятся объекты данных.
Связующее звено между физическим уровнем хранения данных (дисками) и логической организацией (пулами).
Прикреплены к разным OSD, в зависимости от фактора репликации.
Placement group объединяет объекты данных в группы, что позволяет уменьшить количество объектов при операциях внутри кластера.
Placement group хранит данные на нескольких OSD, количество которых равно параметру size.
Objects. Хранятся в pg_num.

Для пула необходимо указывать следующие параметры:
min_size. Минимальное количество копий данных, при наличии которых возможен доступ на запись.
Минимальное количество живых реплик, необходимое для работы пула.
size = Sets the number of replicas for objects in the pool. Количество копий данных.
pg_num = Количество placement group.
pgp_num
crush_rule

Controller replication under scalable hashing.
Карта репликации управляемых масштабируемым хэшированием.
Позволяет клиентам Ceph'a самостоятельно рассчитывать на каком OSD хранить данные и общаться с этим OSD напрямую.
Такой подход позволяет избежать единой точки отказа и избежать проблем, связанных с физическими лимитами на производительность отдельных серверов.
Можно использовать для создания пулов, которые хранят данные только на быстрых серверах или только на медленных.

Install Ceph
git clone scenario
requirements.txt

Переменные, настраивающие кластер находятся по пути **/inventory/group_vars/all.yml**
Откуда ставить репозиторий:
**ceph_origin: repository**
**ceph_repository: community**
**ceph_stable_release: luminous**
**public_network: "172.21.0.0/24"** - сеть, с которой кластер Ceph'a принимает коннекты от клиентов.
**cluster_network: "172.21.0.0/24"** - сеть, в которой компоненты Ceph'a обмениваются между собой информацией.

Демон для синхронизации времени:
**ntp_service_enabled: true**
**ntp_daemon_type: ntpd**

Каким образом хранить свои данные:
**osd_objectstore: bluestore** - есть ещё filestore, но переходят на bluestore.
**osd_scenario: lvm** - collocate and nocollocate - устаревшие сценарии.
При сценарии lvm под хранение данных создаются отдельные lvm-тома. При этом варианте сценарий Ansible пытается автоматически определить какой вариант размещения данных вам нужен.
Для этого он по умолчанию ищет все незадействованные диски, определяет их тип и создаёт на них разделы для хранения данных.
Например, если у вас есть hhd и ssd, то на первых он создаст раздел для хранения данных, а на ssd - раздел для хранения журналов.
Так же можно указать переменную devices, где перечислить на каких конкретно дисках вы хотите размещать свои данные.
**devices:**<br>
  - /dev/sdb<br>
В случае если указан блок **devices** сценарий Ansible не будет искать свободных дисков, а разместит только там, где указано.

Настройки кластера Ceph'a по умолчанию:<br>
ceph_conf_overrides:<br>
  global:
    osd_pool_default_pg_num: 32 - сколько placement group будет создано по умолчанию при создании пула.
    osd_pool_default_pgp_num: 32 - служебная настройка, используемая для разметки placement group. В документации рекомендуется делать её равной pg_num.
    osd_journal_size: 1024 - (в Мега Байтах)
    osd_pool_default_size: 3
    osd_pool_default_min_size: 2 - Количество живых реплик, при которых пул ещё работает. Если их становится меньше, пул прекрашает приём данных на запись до ребалансинга кластера.

##Вычисление pg_num##

Самая главная сложность при вычислении placement group - это соблюдение баланса между количеством групп на одной OSD и их размером.
Чем больше pg на одном OSD, тем больше нужно памяти, чтобы хранить информации об их расположении.
Чем больше размер placement group, тем больше данных будут перемещаться при процедуре балансировки кластера.
Т. о. мало placement group - они большого размера.
Много placement group - нужно больше памяти для демонов OSD.
Теоретическая формула - 1 Гб ОЗУ на 1 Тб памяти.

https://ceph.com/pgcalc/
Пресуппозиция:
принято считать, что на одном OSD оптимально хранить от 100 до 300 placement group.
Т. о. общее количество placement group в кластере (на примере калькулятора ceph.com, берущего за основу 100 pg на OSD) вычисляется по формуле:
Total PGs = (Total_number_of_OSD * 100) / max_replication_count

Более актуальные данные, где можно поиграться и посмотреть на изменения данных в пуле:
https://old.ceph.com/pgcalc/
Т. о. необходимо:
выделять на каждый пул количество PG, пропорционально количеству данных в них
pg_num = Total PGs * % of Size_of_pool/Total_size // Свериться с новыми данными на всякий случай.

прогнозировать изменение количества данных в пулах в будущем

Операция изменения количества placement group присутствует в Ceph, но достаточно ресурсоёмкая.
Во время ребалансинга данных в кластере, половина кластера будет копировать данные из одной placement group в другую.
Поэтому авторы Ceph'a советуют использовать количество групп, равное степеням 2. Т. о. ceph половину данных оставит на старом месте, половину перевезёт.

Основной файл для запуска - site.yml

Команды:
ceph health
ceph -s - информация о кластере
ceph df - информация о количестве данных в кластере.

ceph osd pool create **kube** 32 - создание пула с указанием его имени и количества pg в нём.

ceph osd pool application enable **kube** kubernetes - разрешение на использование пула кубернетесом: enable <имя пула> <название приложения>

Теперь создадим пользователя, дадим ему права на доступ к пулу и сохраним ключ доступа в файл
ceph auth get-or-create client.user mon 'allow r, allow command "osd blacklist"' osd 'allow rwx pool=kube' | tee /etc/ceph/ceph.client.user.keyring
ceph auth get-or-create (получить или создать) client.<name> (имя пользователя с префиксом client)
и список разрешений: кому и на что в формате **mon 'allow rwx' osd 'allow rwx pool=name_pool' etc 'allow etc'**
При успешном выполнении команы появляется строка вида:
[client.our_user_name]
    key = asdfjkl;==
В целях удобства эту информацию нужно сохранить в файл **/etc/ceph/ceph.client.user.keyring** на сервер, к которому будем подключать RBD disk.

Создание диска в пуле:
rbd create **disk1** --size **1G** --pool **kube**

rbd list --pool **kube**

Перед монтированием необходимо поставить на мастер машину ПО Ceph'a:
репозиторий:
yum install -y centos-release-ceph-luminous
пакет:
yum install -y ceph-common

Команда подключения:
Убедиться, что есть файлы:
**/etc/ceph/ceph.conf** и **/etc/ceph/ceph.client.user.keyring**
rbd map **disk1** --pool=**kube** --id=**user** - указываем просто имя пользователя без префикса **.client**.
Ceph client сам автоматически поставит префикс, поищет в директории /etc/ceph/ файл **ceph.client.<user>.keyring** и извлечёт оттуда ключ доступа.

На выходе он сообщает имя нового блочного устройства, например:
**/dev/rbd0**

Теперь на этом блочном устройстве необходимо создать файловую систему:
mkfs.ext4 **/dev/rbd0**

Создаём папку, которую будем монтировать на мастер-машине:
mkdir **/mnt/rbd**
Создаём точку монтирования:
mount **/dev/rbd0 /mnt/rbd**

#Автомонтирование RBD:#

В файле **/etc/ceph/rbdmap** содержится информация о блочных устройствах, которые надо подключать при загрузке.
**echo "pool_name/disk_name id=user_name,keyring=/etc/ceph/ceph.client.user.keyring" >> /etc/ceph/rbdmap**

Включаем автозапуск скрипта rbdmap.
**systemctl enable rbdmap**
**systemctl start rbdmap**

**Монтирование файловой системы**
Добавляем монтирование файловой системы блочного устройства в /etc/fstab командой:
**echo "/dev/rbd/pool_name/disk_name /mnt/rbd ext4 noauto,noatime 0 0" >>/etc/fstab**

Всё, можно перезагрузить сервер и ввести команду **mount** или **df**, чтобы убедиться, что всё работает.

#Монтирование ceph fs#
Команды:
**ceph fs ls**
Должна вернуть название и названия пулов для хранения данных и метадаты.

**cephfs** - это одна общая файловая система.
Для разделения прав доступа различным пользователям назначаются права на отдельные директории это файловой системы.

**Создание пула для CephFS**
//Монтируем на node-1.

**ceph osd pool create "название пула для хранения данных, например, cephfs_data" 32**
**ceph osd pool create "название пула для хранения метаданных, например, cephfs_metadata" 32**
Дальше - создание новой CephFs с указанием пулов для хранения метаданных и самих данных:
**ceph fs new "имя файловой системы, например, cephfs" cephfs_metadata cephfs_data**
**ceph fs ls**

Создаем пользователя для доступа к cephfs:
**ceph auth get-or-create *client.fsuser* mon 'allow r' mds 'allow r, allow rw path=/data_path' osd 'allow rw pool=*cephfs_data*'**
Пользователь создан, ему выданы права чтение-запись на директорию /data_path, но сама директория не создаётся  автоматически.
Надо смонтировать корень cephfs с правами администратора и создать там директорию /data_path.

**mkdir -p /mnt/cephfs**
**mount.ceph "адрес монитора, можно указать все, например: 172.21.200.6":/ /mnt/cephfs -o name=admin,secret=`ceph auth get-key client.admin`**
**mount.ceph** - монтируем файловую систему ceph, / - монтируем корень cephfs. /mnt/cephfs - монтируем туда директорию cephfs на нашем сервере.
опции: под каким юзером монтируем: **-o name, secret**
**mkdir -p /mnt/cephfs/data_path**

Заходим на master-1, монтируем cephfs там с юзером fsuser.

?Получим ключ доступа для юзера **fsuser**:
?**ceph auth get-key client.fsuser**
?
?Сначала положим ключ доступа клиента **fsuser** в файл **/etc/ceph/fsuser.secret**
?**echo "<ключ доступа клиента fsuser>" >/etc/ceph/fsuser.secret**

**mkdir -p /mnt/cephfs**
**mount.ceph** \*\*\*.\*\*.\*\*\*.\*,\*\*\*.\*\*.\*\*\*.\*,\*\*\*.\*\*.\*\*\*.\***:/data_path /mnt/cephfs -o name=fsuser,secretfile=/etc/ceph/fsuser.secret**

#Автомонтирование CephFs#

Настройка монтирования директории cephfs при загрузке сервера master-1:

Сперва убедиться, что на соответствующей машине есть файл с ключом доступа для нужного *юзера*
**cat /etc/ceph/*fsuser*.secret**

Дальше - заполняем файл **/etc/fstab**:
**echo "**\*\*\*.\*\*.\*\*\*.\*,\*\*\*.\*\*.\*\*\*.\*,\*\*\*.\*\*.\*\*\*.\***:/ /mnt/cephfs ceph name=*fsuser*,secretfile=/etc/ceph/fsuser.secret,**\_**netdev,noatime 0 0">>/etc/fstab**
secterfile - опция, указывающая путь к файлу с секретом.
\_netdev - опция, которая говорит о том, что устройство - сетевое и монтировать его надо только после того, как смонтирован и запущен сетевой стек.

Если у вас останутся подмонтированы каталоги, не упомянутые в /etc/fstab, то во время выключения системы сначала будет потушен сетевой интерфейс и только потом начнутся попытки отмонитровать подключение сетевого диска. Эти попытки будут неудачными и будут повторятся  целых 30 минут, пока не истечет глобальный таймаут на server shutdown.
Если же точка монтирования есть в /etc/fstab, и у неё указана опция \_netdev, то такой каталог будет отмонтирован до выключения сетевого интерфейса.

#Мониторинг#

На каждом сервере, где установлен MGR, нужно установить zabbix:

yum install zabbix-sender

ceph zabbix config-set zabbix_host zabbix.slurm.io
ceph zabbix config-set identifier node-1.slurm.io
ceph mgr module enable zabbix

Documentation:
http://docs/ceph.com/docs/master/mgr/zabbix

ceph health             Здоровье
ceph -s          	    Статус всего
ceph df                 статистика по занятому месту
ceph auth list          список прав клиентов
ceph mon dump           список мониторов
ceph osd dump           список пулов, osd и триггеров
ceph osd tree           список OSD с весам алгоритма CRUSH
ceph tell osd.X bench 	тестирование скорости доступа к osd.X

https://docs.ceph.com/en/latest/rados/operations/monitoring/

# Практическая работа с кубернетес

Проверяем, что Ceph живой:
ceph health
ceph -s

  cluster:
    id:     77f26405-5f53-47c8-af1c-cc5bcdc198e1
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum ingress-1,node-1,node-2 (age 26m)
    mgr: ingress-1(active, since 25m), standbys: node-2, node-1
    mds: cephfs:1 {0=ingress-1=up:active} 2 up:standby
    osd: 3 osds: 3 up (since 24m), 3 in (since 24m)

  data:
    pools:   2 pools, 64 pgs
    objects: 22 objects, 2.2 KiB
    usage:   3.0 GiB used, 27 GiB / 30 GiB avail
    pgs:     64 active+clean

Создаем пул в Ceph'e для RBD дисков
3) Запускаем на node-1
**ceph osd pool create kube(имя) 32**
После этой команды:
    pools:   3 pools, 96 pgs
**ceph osd pool application enable kube rbd**
enabled application 'rbd' on pool 'kube'

Получаем файл с настройками chart
4) Переключаемся на master-1 и добавляем репозиторий с chart'ом, получаем набор переменных chart'a ceph-csi-rbd
helm repo add ceph-csi https://ceph.github.io/csi-charts
helm inspect values ceph-csi/ceph-csi-rbd > cephrbd.yml

Заполняем переменные в cephrbd.yml
5) Выполняем на node-1, чтобы узнать необходимые параметры:

Получаем clusterID
**ceph fsid**
Получаем список мониторов кластера Ceph
**ceph mon dump**

6) Переключаемся снова на master-1 и правим файл cephrbd.yml

Заносим свои значение clusterID, и адреса мониторов. Включаем создание политик PSP, и увеличиваем таймаут на создание дисков Список изменений в файле cephrbd.yml. Опции в разделах nodeplugin и provisioner уже есть в файле, их надо исправить так, как показано ниже.

csiConfig:
  - clusterID: "bcd0d202-fba8-4352-b25d-75c89258d5ab"
    monitors:
      - "v2:172.18.8.5:3300/0,v1:172.18.8.5:6789/0"
      - "v2:172.18.8.6:3300/0,v1:172.18.8.6:6789/0"
      - "v2:172.18.8.7:3300/0,v1:172.18.8.7:6789/0"

nodeplugin:
  podSecurityPolicy:
    enabled: true

provisioner:
  replicaCount: 1
  podSecurityPolicy:
    enabled: true

Устанавливаем чарт

7) Выполняем команду
helm upgrade -i ceph-csi-rbd ceph-csi/ceph-csi-rbd -f cephrbd.yml -n ceph-csi-rbd --create-namespace

8) Создаем пользователя в ceph, с правами записи в пул kube

Запускаем на node-1
**ceph auth get-or-create client.rbdkube mon 'profile rbd' osd 'profile rbd pool=kube'**

9) Смотрим ключ доступа для пользователя rbdkube
**ceph auth get-key client.rbdkube**

10) Заполняем манифесты
Выполняем на master-1, подставляем значение ключа в манифест секрета.

cd ~/slurm/practice/7.datastorage/rbd/
vim secret.yaml

11) Создаем секрет
kubectl apply -f secret.yaml
12) Получаем id кластера ceph
ceph fsid
13)  Заносим clusterid в storageclass.yaml
14) Создаем storageclass
kubectl apply -f storageclass.yaml

15) Создаем pvc, и проверяем статус и наличие pv

kubectl apply -f pvc.yaml
kubectl get pvc
kubectl get pv

16) Получаем список томов в пуле и просматриваем информацию о томе

Выполняем на node-1
rbd ls -p kube
rbd -p kube info csi-vol-eb3d257d-8c6c-11ea-bff5-6235e7640653

# Практика с установкой CephFS

1) Заходим на master-1 и получаем переменные chart'a ceph-csi-cephfs

(ставить будем версию 2.1.2, потому что в версиях 3.x.x опять сломали изменение размера тома)

helm repo add ceph-csi https://ceph.github.io/csi-charts
helm inspect values ceph-csi/ceph-csi-cephfs --version 2.1.2 >cephfs.yml

2) Выполняем на node-1, чтобы узнать необходимые параметры:

ceph fsid
ceph mon dump

3) Возвращаемся на master-1 и правим файл cephfs.yml

nodeplugin:
  podSecurityPolicy:
    enabled: true

provisioner:
  replicaCount: 1
  podSecurityPolicy:
    enabled: true

Устанавливаем чарт
4) Запускаем на master-1

helm upgrade -i ceph-csi-cephfs ceph-csi/ceph-csi-cephfs -f cephfs.yml -n ceph-csi-cephfs --create-namespace  --version 2.1.2 

5) Создаем пользователя для cephfs
Возвращаемся на node-1

ceph auth get-or-create client.fs mon 'allow r' mgr 'allow rw' mds 'allow rws' osd 'allow rw pool=cephfs_data, allow rw pool=cephfs_metadata'

6) Посмотреть ключ доступа для пользователя fs
ceph auth get-key client.fs

7) Заполняем манифест secret.yml
Выполняем на master-1

Заносим имя пользователя fs и значение ключа в

adminID: fs
adminKey:

8) Создаем секрет

kubectl apply -f secret.yaml

10) Заносим clusterid в storageclass.yaml
11) Создаем storageclass

Проверяем создание директории в cephfs

13) монтируем CephFS на node-1

Выполняем на node-1

Точка монтирования

mkdir -p /mnt/cephfs

Создаем файл с ключом администратора

ceph auth get-key client.admin >/etc/ceph/secret.key

Добавляем запись в /etc/fstab
!!! Изменяем ip адрес на адрес узла node-1

echo "172.<xx>.<yyy>.6:6789:/ /mnt/cephfs ceph name=admin,secretfile=/etc/ceph/secret.key,noatime,_netdev 0 2">>/etc/fstab


mount /mnt/cephfs

14) Идем в каталог /mnt/cephfs и смотрим что там есть

cd /mnt/cephfs

15) Изменяем размер тома в манифесте pvc.yaml

Возвращаемся на master-1

vi pvc.yaml

resources:
  requests:
    storage: 7Gi

kubectl apply -f pvc.yaml

16) Проверяем на node-1

yum install -y attr

getfattr -n ceph.quota.max_bytes <каталог-с-данными>
