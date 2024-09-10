# Token deploy
In more recent versions, including Kubernetes v1.30, API credentials are obtained directly using the TokenRequest API, and are mounted into Pods using a projected volume. The tokens obtained using this method have bounded lifetimes, and are automatically invalidated when the Pod they are mounted into is deleted.<br>
You can still manually create a Secret to hold a service account token; for example, if you need a token that never expires.<br>
Once you manually create a Secret and link it to a ServiceAccount, the Kubernetes control plane automatically populates the token into that Secret.<br>
[Source](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/)

# Последовательность действий для настройки автоматизации деплоя
1. Create SA.<br>
Вначале должен быть создан Service Account, через который мы будем совершать деплой.<br>
2. Role Binding SA.<br>
Связываем Service Account с нужной ролью, (например, Admin или Jenkins для тестовых сред для возможности деплоить ресурсы без сильных ограничений).<br>
3. Создаём токен.<br>
В случае мануального создания токена, с неограниченным сроком жизни делаем следующее:<br>
Создаём секрет.<br>
Пример:
```
kubectl apply -f - <<EOF
kind: Secret
apiVersion: v1
metadata:
  # Имя токена (будет отображаться в Secrets)
  name: jenkins-token
  # Указываем namespace проекта, для которого делаем токен
  namespace: your-namespace-is-here
  annotations:
    # Тут надо вставить имя ServiceAccount, для которого делаем токен
    kubernetes.io/service-account.name: "jenkins"
type: kubernetes.io/service-account-token
EOF
```
4. Чтобы созданный токен заработал его надо также слинковать с SA, дописав в YAML список "secrets" после metadata:
```
secrets:
- name: jenkins-token
```
При ручной привязке persistence token'a:
```
kubectl patch serviceaccounts jenkins -p '{"secrets": [{"name": "jenkins-token"}]}'
```
