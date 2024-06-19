**Admission Controller** — это расширение API-сервера Kubernetes, которое позволяет выполнять дополнительные проверки, модификации и манипуляции с объектами Kubernetes перед тем, как они будут созданы, изменены или удалены в кластере. Он предоставляет механизм для внедрения пользовательской логики на этапе входящего запроса к API-серверу, что обеспечивает дополнительные уровни безопасности и валидации.

В целом, концепция Admission controllers состоит из следующих основных этапов:
1. API HTTP handler
2. Authentification/Authorization
3. Mutating admission (mutating webhooks)
4. Schema validation
5. Validating admission (validating webhooks)
6. Persisted to etcd

То есть сперва на API приходит запрос, затем на сервере KubeAPI происходит аутентификация и авторизация, далее происходит проверка данных и схемы с помощью веб-хуков и только потом запись идет в хранилище etcd.<br>
Admission controller могут быть валидирующими (validating), мутирующими (mutating) или сразу обоими.<br>
Мутирующие изменяют объекты, валидирующие нет.<br>
Процесс admission controller происходит в два этапа. Сначала выполняются мутирующие контроллеры, а затем уже валидирующие. Если какой-либо контроллер отклоняет запрос, то весь запрос отклоняется сразу же и ошибка возвращается конечному пользователю.

Admission Controllers могут быть запущены как встроенные (built-in) или пользовательские (custom).<br>
Встроенные Admission Controllers уже включены в API-сервер, и их можно просто включать при необходимости.

Вот некоторые типовые встроенные варианты:
* **ResourceQuota.** Контролирует количество ресурсов (CPU, память) и объектов (поды, сервисы) в пространствах имён.
* **SecurityContextDeny.** Запрещает создание объектов без установленных Security Context, что повышает безопасность.

**Admission Webhook** представляет собой HTTP-сервер, который используется в Admission Controller для выполнения дополнительных проверок и манипуляций с объектами Kubernetes перед их созданием, изменением или удалением.<br>
Так, если мы задеплоили что-то непозволительное, то Admission webhook дёрнет запрос на HTTP-сервере, после чего произойдёт следующее:<br>
admission Controller увидит несоответствие и вернёт отказ через Admission Webhook в формате AdmissionReview API Kubernetes. Этот ответ содержит информацию о том, разрешён запрос или нет, а также может включать в себя какие-то дополнительные данные.

Источники:<br>
https://habr.com/ru/companies/gazprombank/articles/753622/<br>
https://habr.com/ru/companies/otus/articles/718178/<br>

Mutating admission webhooks allow you to “modify” a (e.g.) Pod (or any kubernetes resource) request. E.g. you can modify a Pod to use a particular scheduler, add / inject sidecar containers, or even reject it if it doesn’t meet some security requirements, etc. etc. — all without having to write a full fledged “micro” service to do this.

The MutatingWebhookConfiguration is where we tell k8s which resource requests should be sent to our webhook. The configuration consists of the following properties:
* apiVersion (at the time it is: admissionregistration.k8s.io/v1beta1)
* kind (must be: MutatingWebhookConfiguration)
* metadata (the usual: name, annotations, labels)
* webhooks (a list of type webhook)

The webhook (type) consists of these properties:
* name
* clientConfig
* - caBundle (we will get this from the k8s cluster itself)
* - service to send the AdmissionReview requests to
* rules ( a list of rules that define which resource operations should be matched, these rules make sure that k8s resource requests are sent to your webhook )
* namespaceSelector (the usual: matchLabels: {“label_name”: “label_value”}

The full list of properties can be seen
https://pkg.go.dev/k8s.io/api/admissionregistration/v1beta1#MutatingWebhook

A rule consists of the following:
* operations (a list of [operations](https://godoc.org/k8s.io/api/admissionregistration/v1beta1#OperationType) to match, in our case ["CREATE"])
* apiGroups (in our case, empty [""])
* apiVersions (in our case, this is ["v1"])
* resources (in our case, this is ["pods"])

Here is an example:
```
---
apiVersion: admissionregistration.k8s.io/v1beta1
kind: MutatingWebhookConfiguration
metadata:
 name: mutateme
 labels:
 app: mutateme
webhooks:
 - name: mutateme.default.svc.cluster.local
 clientConfig:
 caBundle: ${CA_BUNDLE}
 service:
 name: mutateme
 namespace: default
 path: "/mutate"
 rules:
 - operations: ["CREATE"]
 apiGroups: [""]
 apiVersions: ["v1"]
 resources: ["pods"]
 namespaceSelector:
 matchLabels:
 mutateme: enabled
```

The ${CA_BUNDLE} above refers to the actual CA bundle retrieved from the k8s API, replace it with your own; you can get your cluster’s CA bundle with
```
kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}'
```

Source:
https://dev.to/ineedale/writing-a-very-basic-kubernetes-mutating-admission-webhook-5b1
