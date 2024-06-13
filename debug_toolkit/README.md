В этот раздел я помещаю написанные Jenkins jobs, которые помогают точнее локализовать где именно происходит проблема в процессе настройки CI/CD с помощью Jenkins.<br>
[Проверка доступа в Nexus](#jen_nexusgroovy)<br>
[Проверка доступа в кластер Openshift](#jen_osegroovy)<br>
[Проверка доступа в кластер Kubernetes](#jen_kubegroovy)<br>
Уточнить тип item.<br>
Навскидку - pipeline script<br>
На будущее - докинуть Jenkinsfile из Multibranch pipeline.<br>

**Предварительный глоссарий**.<br>
Во всех примерах используется механизм определения версии инструмента из [custom tool plugin Jenkins](https://github.com/jenkinsci/custom-tools-plugin/tree/master)<br>
Если этого плагина нет, но версии инструментов на агентах различаются, необходимо выбрать иной способ определять версию инструментов.

# jen_nexus.groovy

Это scripted pipeline, node label задаётся в разделе node.<br>
(Сделать вынос в переменные).<br>
Может помочь для диагностики есть ли соединение и доступ у Jenkins agent'a к требуемому пространству Nexus в случаях, когда на этапе забора/публикации артефактов возникает какая-то ошибка.<br>

Для запуска необходимы:
* Jenkins credential типа "Username with password", под которым производятся нужные операции с Jenkins'ом
* адрес Nexus'a к необходимому пространству<br>
(добавить примеры, когда запрос идёт не только к maven, но и к docker registry)
* указать node label

# jen_ose.groovy

Это declarative pipeline для проверки возможности Jenkins agent'a коннектиться к нужному api серверу **Openshift** и проводить деплой нужных ресурсов.<br>
К последней операции:
```
oc api-resources --namespaced=true -o wide
```
можно добавлять grep для фильтрации и просмотра списка операций (watch, create, etc.) с нужными ресурсами.<br>
For example:
```
oc api-resources --namespaced=true -o wide | grep -i secret
```
Node label вынесена в global vars.<br>

В блоке environment задаются:
* api server k8s, к которому необходим коннект
* namespace, где проверяется возможность подключения и деплоя
* используемая версия tool oc (Openshift client), взятая из Pipeline Syntax Snippet Generator (custom tools plugin)<br>

Также для запуска необходимы:
* Jenkins credential типа "Secret string", содержащая в себе токен аутентификации к кластеру Openshift
* указанная node label

# jen_kube.groovy

Это declarative pipeline для проверки возможности Jenkins agent'a коннектиться к нужному api серверу **Kubernetes** и проводить деплой нужных ресурсов.<br>
Для этой джобы характерны те же пререквизиты и требования проверки доступа Service Account token'a, что и для [проверки доступа в кластер Openshift](#jen_osegroovy)<br>
