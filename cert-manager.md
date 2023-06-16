# Custom Resource Definition
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

Список команд, которые позволят установить cert-manager в свой кластер:

**В начале добавляем объекты CRD**:
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml

kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager \
 --namespace cert-manager \
 --version v1.7.1 \
 --set ingressShim.defaultIssuerName=letsencrypt \
 --set ingressShim.defaultIssuerKind=ClusterIssuer \
 jetstack/cert-manager


