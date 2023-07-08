Встроенные подсказки:
**kubectl explain pod** - можно посмотреть описание всех доступных полей в pod'e
**kubectl explain pod.spec** - или внутри spec'а pod.

Command указывается внутри описания контейнера. На одном уровне с image и name.
spec:
  containers:
  - image: nginx:1.12 // После containers первая строка - дефис. Потому что у пода **список** контейнеров и указывать их здесь можно много, просто добавляя следующим элементом.
    name: nginx
    ports:
    - containerPort: 80

Попробовать на разных ресурсах:
**kubectl edit replicaset my-replicaset** - править манифест как он есть в кубере.
Повторно ознакомиться с командой **kubectl create** и попробовать передачу переменных.

**kubectl set** - установить значение переменной однострочником.
Пример: перевести версию nginx from 1.12 to 1.13:
kubectl set **image** replicaset[resource] my-replicaset[resource's name] nginx=nginx:1.13 **[key=value]**

kubectl get po <ИМЯ НОВОГО POD'а> -o=jsonpath='{.spec.containers[\*].image}{"\n"}'
Ключ -o jsonpath позволяет получить не весь объект целиком, а только содержимое конкретных полей.
Он крайне полезен при написании скриптов для автоматизации задач в Kubernetes.

**kubectl get deployment my-deployment -o custom-columns='NAME:.metadata.name,MAXSURGE:.spec.strategy.rollingUpdate.maxSurge,MAXUNAVAILABLE:.spec.strategy.rollingUpdate.maxUnavailable'** выводит следующий результат:
NAME            MAXSURGE   MAXUNAVAILABLE
my-deployment   1          0
Это еще одна возможность ключа -o. Она позволяет вывести описание объекта с пользовательским набором полей.

**sh -c 'while true; do echo "Hello, ${USERNAME}!"; sleep 2; done'**
Значение для переменной окружения ${USERNAME} должно передаваться при запуске replicaset'а из env.
    Для указания переменных окружения используется поле env. Оно указывается внутри описания контейнера. На одном уровне с image и name.
    Пример:
    env:
    - name: VAR_NAME
      value: var-value

**kubectl delete all --all** - команда для удаления всех объектов в кластере с любым именем.

**describe pod** также показывает успешность или неуспешность всех проб:
readinessProbe - контролирует, что приложение запустилось и готово принимать клиентов.
livenessProbe - контролирует, что приложение нормально функционирует и всё ещё может принимать клиентов.

**kubectl get po --show-labels** - показывает поды со всеми метками, которые у них есть.
**kubectl get ep** - сокращённо от endpoints. Так как они создаются, например, вместе с сервисом, позволяет узнать эндпоинты, на которые отправляется трафик.
**kubectl get pod -o wide** - показывает ip-адреса подов. Сервис по меткам (--show-labels) нашёл поды, на которые он балансирует трафик и в объект **endpoints** занёс их адреса и порты.


Самый быстрый способ в случае проблем с controlplane кластера продиагностировать неисправность - это выполнить команду
**kubectl get componentstatuses**
