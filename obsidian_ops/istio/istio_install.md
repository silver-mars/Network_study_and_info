# Istio install

Установить версию Istio можно командой:
```
 curl -L https://git.io/getLatestIstio | sh - Sh -
```
Можно также указать точечную версию:
```
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.1.0 sh -
```

Каждый релиз включает istioctl (двоичный файл, соответствующий выбранной ОС), примеры конфигурации, пример приложения и установочные ресурсы для конкретной платформы.<br>
Кроме того, istioctl – важный инструмент командной строки для администраторов, помогающий в отладке и диагностике сервисных сеток Istio, – можно установить с  помощью диспетчера пакетов.<br>

В каталоге install/ находятся установочные инсталляционные YAML-файлы Istio для Kubernetes, в samples/ - примеры приложений и в bin/ - двоичный файл клиента istioctl.<br>

Утилиту istioctl можно использовать для создания правил и политик маршрутизации, а также для внедрения экземпляров прокси Envoy вручную. Другие области применения включают создание, перечисление, изменение и удаление ресурсов конфигурации в системе Istio.<br>

Правильность установки istioctl можно проверить, запустив:
```
istioctl version
```
## CRD
Пример регистрации crd istio:
```
for i in install/kubernetes/helm/istio-init/files/crd\*yaml;
  do kubectl apply -f $i; done
```
Проверка:
```
kubectl get crd | grep istio
```
Использование команды istioctl proxy-status позволяет получить обзор сетки.<br>
Определяем метку пространства имен по умолчанию, как istio-injection=enabled:
```
kubectl label namespace default istio-injection=enabled
```
