Helm - "пакетный менеджер" kubernetes.
Helm действительно использует "пакеты" для своей работы, они располагаются в его репозитории и называются **charts**.
Их можно скачивать, разворачивать, удалять, менять, самостоятельно заводить свои репозитории и хранить данные приватно.
**Chart** - это .tgz (targzip-архив), в котором лежат:
* набор тэймплейтированных манифестов нашего приложения
(сервисы, ингрессы, деплойменты и т. д.)
* файл со значениями переменных
(какие именно values надо поставить в наше тэймплейтированное приложение)
* метаинформация о нашем пакете
(кто разработчик, где лежит исходный код и т. д.)

С помощью Helm можно осуществлять откат любых объектов Kubernetes

# Инструкция к применению
0. Добавляем официальный stable репозиторий
helm repo add stable https://charts.helm.sh/stable
1. Обновляем репозиторий
Helm repo update
Факультативно:
пример поиска репозиториев:
helm search hub kube-ops
2. Открываем на редактирование файл values.yaml и в нем изменяем
ingress.enabled=true,
ingress.hostname=<...>,
rbac.create=true
3. Запускаем установку приложения
helm install kube-ops-view (название чарта, которое будет видно в нашем кластере) stable/kube-ops-view (из какого репозитория брать чарт) --namespace (в какой нэймспейс) kube-system -f values.yaml (values - взять из локального файла)

**Факультативно:**
* Проверка установленных релизов
helm ls --namespace kube-system
* Удаление установленных пакетов
helm uninstall kube-ops-view --namespace kube-system
рекомендуется удалять через helm то, что было через него установлено.
* Можно скачать все файлы этого чарта:
helm pull stable/kube-ops-view --untar (если нужно сразу разархивировать

**Commands**
helm template . // указание корневого файла, где лежат templates. Воспроизводит как будет выглядеть файл
helm template --name-template <abc>
helm create <name> // создание стартера из шаблона helm, где <name> - название проекта и родительской директории

Директория **helm/tests** - может быть заполнена тестами.
Если это происходит, то в аннотации нужно указать: **helm.sh/hook: test**
а в самом скрипте: **helm test <release_name>**

Example:
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ .Release.Name }}-credentials-test"
  annotations:
    "helm.sh/hook": test
  spec:
    template:
      spec:
        containers:
        - name: main
          image: {{ .Values.image }}
          env:
            etc.
        command: ["sh", "-c", <...>]

**Hooks**
Используемых команд довольно много:
1. pre-install, post-install, pre-uninstall, post-uninstall, pre-upgrade, post-upgrade, pre-rollback, post-rollback
2. Это те же манифесты k8s
3. Одинаковые хуки сортируются по весу и имени объекта (два pre-install, etc)
4. Сперва отрабатывают объекты с меньшим весом (от - к +)
5. Хуки не входят в релиз (helm.sh/hook-delete-policy)

Example:
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ .Release.Name }}"
  labels:
    app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
    app.kubernetes.io/instance: {{ .Release.Name | quote }}
    app.kubernetes.io/version: {{ .Chart.AppVersion }}
    helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
  annotations:
    # This is what defines this resource as a hook. Without this line, the
    # job is considered part of the release
    "helm.sh/hook": post-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded
etc.



