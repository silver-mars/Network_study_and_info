# Custom Resource Definition
Автоматизирует получение SSL/TLS-сертификатов из различных удостоверяющих центров.
Выписывает, подключает и автоматически продлевает сертификаты.
Интегрируется с ingress-controller'ом, что означает что ручные вмешательства минимальны.

Cert Manager использует объекты CRD:

Два объекта, которые выдают сертификаты:
**Issuer** - объект, работающий в рамках одного нэймспейса
**ClusterIssuer** (объект, описывающий наш удостоверяющий центр). Работает в рамках всего кластера.
**Certificate** - не сам сертификат, а его описание. Домен, на который нужно выписать, способ, описание Issuer' и т. д.
Два объекта CRD, которые относятся к валидации домена:
создаются автоматически, в момент создания объекта Certificate.
**Order**
**Challenge**

Также при установке cert-manager'a устанавливается его RBAC.


**Список команд, которые позволят установить cert-manager в свой кластер**.
Обновлённый и поддерживаемый в актуальном состоянии туториал находится здесь:
https://artifacthub.io/packages/helm/cert-manager/cert-manager

**В начале добавляем объекты CRD**:
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.2/cert-manager.crds.yaml

customresourcedefinition.apiextensions.k8s.io/certificaterequests.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/certificates.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/challenges.acme.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/clusterissuers.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/issuers.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/orders.acme.cert-manager.io created

kubectl create namespace cert-manager

## Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager \
 --namespace cert-manager \
 --version v1.7.1 \
 --set ingressShim.defaultIssuerName=letsencrypt \
 --set ingressShim.defaultIssuerKind=ClusterIssuer \
 jetstack/cert-manager

NAME: cert-manager
LAST DEPLOYED: Tue Jun 20 17:32:04 2023
NAMESPACE: cert-manager
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
cert-manager v1.7.1 has been deployed successfully!

Далее.
1. Проверяем, что все pod'ы запустились. У всех должен быть статус Running. Pod с webhook в версии 0.12 у меня поднимался около двух с половиной минут, потому что он хочет смонтировать секрет с сертификатом cert-manager-webhook-tls, а этот сертификат создается не очень быстро.

kubectl -n cert-manager get po -w

2. Проверяем работу cert-manager, выпустив самоподписанный сертификат:
kubectl apply -f test-resources.yaml

После применения манифеста должен появиться ресурс типа certificate с именем selfsigned-cert. Посмотрим его описание и манифест:
**kubectl -n cert-manager-test get certificate**
**kubectl -n cert-manager-test describe certificate selfsigned-cert**
Events:
  Type    Reason     Age    From          Message
  ----    ------     ----   ----          -------
  Normal  Issuing    2m35s  cert-manager  Issuing certificate as Secret does not exist
  Normal  Generated  2m35s  cert-manager  Stored new private key in temporary Secret resource "selfsigned-cert-5cbvg"
  Normal  Requested  2m35s  cert-manager  Created new CertificateRequest resource "selfsigned-cert-wpx5p"
  Normal  Issuing    2m35s  cert-manager  **The certificate has been successfully issued**
**kubectl -n cert-manager-test get certificate selfsigned-cert -o yaml**
status:
  conditions:
  - lastTransitionTime: "2023-06-20T14:35:06Z"
    message: Certificate is up to date and has not expired
    observedGeneration: 1
    reason: Ready
    status: "True"
    type: Ready

3. Удаляем тестовый namespace, и после этого продолжим
kubectl delete ns cert-manager-test

**Околобоевая подготовка**.
Для выпуска сертификатов от Let's Encrypt надо создать сущность ClusterIssuer, в которой указать url ACME сервера, e-mail и секрет. В нём будет храниться информация для авторизации в letsencrypt.

1. Для учебных целей применяем манифест, в котором указан url от тестового stage ACME сервера
**kubectl apply -f clusterissuer-stage.yaml**

В файле clusterissuer.yaml находится Issuer, который выписывает рабочие сертификаты от lestencrypt, вы можете использовать его в своих кластерах, только не забудьте поменять e-mail в манифесте. На учебном кластере этот манифест применять не надо, потому что лимиты от letsencrypt достаточно жесткие.

Исправляем поля host в манифесте tls-ingress.yaml  (укажите ваш номер студента в двух местах) и применим его:
**kubectl apply -f tls-ingress.yaml -n default**

Проверяем созданный сертификат и секреты
**kubectl get certificate my-tls -o yaml**
**kubectl get secret my-tls -o yaml**

 Убедимся, что сертификат подписан stage CA от letsencrypt

curl https://my.sXXXXXX.edu.slurm.io -k -v

* Server certificate:
*       subject: CN=my.sXXXXXX.edu.slurm.io
*       start date: Jun 17 14:20:23 2019 GMT
*       expire date: Sep 15 14:20:23 2019 GMT
*       common name: my.sXXXXXX.slurm.io
*       issuer: CN=(STAGING) Artificial Apricot R3,O=(STAGING) Let's Encrypt,C=US
