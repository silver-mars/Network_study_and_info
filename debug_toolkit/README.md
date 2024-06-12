В этот раздел я помещаю написанные Jenkins jobs, которые помогают точнее локализовать где именно происходит проблема в процессе настройки CI/CD с помощью Jenkins.<br>
[Проверка доступа в Nexus](#jen_nexusgroovy)<br>
[Проверка доступа в кластер Openshift](#jen_osegroovy)<br>
Уточнить тип item.<br>
Навскидку - pipeline script<br>
На будущее - докинуть Jenkinsfile из Multibranch pipeline.

# jen_nexus.groovy

Это scripted pipeline, node label задаётся в разделе node.<br>
(Сделать вынос в переменные).<br>
Может помочь для диагностики есть ли соединение и доступ у Jenkins agent'a к требуемому пространству Nexus в случаях, когда на этапе забора/публикации артефактов возникает какая-то ошибка.<br>

Для запуска необходимы:
* Jenkins credential типа "Username with password", под которым производятся нужные операции с Jenkins'ом
* адрес Nexus'a к необходимому пространству<br>
(добавить примеры, когда запрос идёт не только к maven, но и к docker registry)
* указать метку agent'a

# jen_ose.groovy

Это declarative pipeline для проверки возможности Jenkins agent'a коннектиться к нужному api серверу k8s и проводить деплой нужных ресурсов.<br>
К последней операции:
```
oc api-resources --namespaced=true -o wide
```
можно добавлять grep для фильтрации и просмотра списка операций (watch, create, etc.) с нужными объектами.<br>
For example:
```
oc api-resources --namespaced=true -o wide | grep -i secret
```
Node label вынесена в global vars.<br>

В блоке environment задаются:
* используемая версия tool oc (Openshift client), взятая из Pipeline Syntax
* api server k8s, к которому необходим коннект
* namespace, где проверяется возможность подключения и деплоя

Для запуска необходимы:
* Jenkins credential типа "Secret string", содержащая в себе токен аутентификации к кластеру k8s
* url api server k8s
* указать node label
* и используемую версию oc, если их несколько и используется механизм pipeline syntax
(Внести дополнительную информацию об этом механизме или убрать его из скрипта).
