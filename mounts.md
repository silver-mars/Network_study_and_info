На уровне контейнера есть volumeMounts:

Example:
spec:
  containers:
  - image: k8s.gcr.io/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /test // в какую именно директорию внутри контейнера подключается
      name: test-volume
    volumes: // на уровень выше - описание всех томов, используемых в поде
    - name: test-volume
    <...>

В реальности чаще всего используются несколько типов томов:
**secret, configMap** - позволяют создать в контейнере том с файлами из манифестов кубернетес.
**emptyDir** - создаёт пустой временный том, который будет удалён вместе с подом, который его использует.
**hostPath** - позволяет смонтировать внутрь контейнера любую директорию с локального диска сервера.

**Подключение к подам SC/PVC/PV**

**Storage class**: хранит тип и параметры подключения к системе хранения данных.
Необходимы kubelet'у, чтобы смонтировать том к себе на узел.
**PersistentVolumeClaim**: описывает требования к тому данных (как правило размер и называние Storage Class'a)
**PersistentVolume**: хранит параметры и статус тома.
Здесь указывается Storage class и идентификаторы диска в системе хранения данных.
**Provisioner**: параметр SC, плагин создания томов.

Таким образом, при создании PVC k8s:
1. Смотрит том какого размера и из какого Storage class'a нам необходим,
2. Подбирает свободный PersitentVolume, подходящий под условия.
3. Если свободного PV нет, k8s может запустить специальную программу Provisioner, название которой указывается в манифесте Storage Class'a.
Эта программа
подключается к системе хранения данных,
создаёт том нужного размера,
получает идентификатор и
создаёт в кластере k8s манифест PersistentVolume, который связывается с PVC.

Таким образом все параметры подключения к системе хранения данных находятся в storage class'е.

Сейчас уже появился Container Storage Interface - унифицированный интерфейс хранилищ.
