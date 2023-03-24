CNI (Container Network Interface) состоит из 3-ёх частей:

1. Спецификации.
Определяет API между исполняемой средой (runtime) контейнера и сетевыми плагинами.
Обязательные поддерживаемые операции (добавление контейнера в сеть и удаление его оттуда),
список параметров,
формат конфигурации сети и их списков (хранятся в JSON), а также известных структур (IP-адресов, маршрутов, DNS-серверов).
Пример конфигурации сети в CNI:
{
  "cniVersion": "0.3.1",
  "name": "dbnet",
  "type": "bridge",
  "bridge": "cni0",
  "ipam": {
    "type": "host-local",
    "subnet": "10.1.0.0/16",
    "gateway": "10.1.0.1"
  },
  "dns": {
    "nameservers": [ "10.1.0.1" ]
  }
}

2. Официальных плагинов.
Предоставляют сетевые конфигурации для разных ситуаций и служат примером соответствия спецификации CNI.
Они доступны в containernetworking/plugins и разбиты на 4 категории:
main (loopback, bridge, ptp, vlan, ipvlan, macvlan),
ipam (dhcp, host-local),
meta (flannel, tuning),
sample.
Все написаны на Go.

3. Библиотеки (libcni)
Предлагают реализацию спецификации CNI (тоже на языке Go) для удобного использования в исполняемых средах контейнеров.

# Calico #

В NetworkPolicy Calico использует подход «Запрети всё и явно открывай необходимое».
curl https://docs.projectcalico.org/v3.10/manifests/calico.yaml -O

#Сетевая модель Kubernetes#

# Наиболее фундаментальный труд, без которого никуда нельзя.
# Да, мы таки дошли до СДСМ.
https://linkmeup.ru/blog/1188/

#Непременно прочесть этот материал, поскольку он и про ip-адреса в целом, и про расчёт масок подсети, и про основы работы компьютерных сетей подробно.
https://zametkinapolyah.ru/kompyuternye-seti/4-6-besklassovye-seti-cidr-maska-podseti-seti-peremennoj-dliny-vlsm-v-protokole-ip.html?ysclid=lfl4kg2qzl641259348

Виртуальная сеть Л2 и Л3 + много разных сетевых сложностей точка-точка и т. д.:
https://habr.com/ru/post/354408/

NetWorkPolicy: (CNI их реализует)
https://habr.com/ru/company/flant/blog/443190/

Сетевая модель Kubernetes, начиная с ip pod'a:
https://habr.com/ru/company/flant/blog/346304/

3-я часть сетевой модели, которую я ещё не читал:
https://habr.com/ru/company/flant/blog/433382/
