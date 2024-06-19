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

The full list of properties can be seen<br>
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

Source:<br>
https://dev.to/ineedale/writing-a-very-basic-kubernetes-mutating-admission-webhook-5b1
