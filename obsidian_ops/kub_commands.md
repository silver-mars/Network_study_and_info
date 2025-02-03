# --dry-run
To use the kubectl dry run command, simply include the --dry-run flag when applying a resource configuration.<br>
Example:
```
kubectl apply -f my-resource.yaml --dry-run
```
This will output the changes that would be made if you were to apply my-resource.yaml, but without actually applying them.<br>

By default, kubectl dry run will output the changes in YAML format. However, you can also specify a different output format using the --output flag. For example:
```
kubectl apply -f my-resource.yaml --dry-run --output=json
```
The kubectl dry run command is a powerful tool that allows you to preview changes to your Kubernetes resources before actually applying them. By using dry run, you can catch errors and unintended consequences before they occur, and ensure that your Kubernetes cluster remains stable and reliable.<br>

You can also use the --output flag with the diff command to see a side-by-side comparison of the current resource configuration and the proposed changes:
```
kubectl diff -f my-resource.yaml --dry-run --output=wide
```

# diff
That's exactly what kubectl diff does: It shows that changes that an kubectl apply would make if we apply them but without actually making any changes. If there's no actual change it will just return a 0 as an exit code without any output:<br>
```
kubectl diff -f my-resource.yaml
```

# Create secret

```
kubectl create secret generic name_secret --from-file=key=path_to_file
# example:
kubectl create secret generic tls_secret --from-file=tls.key=tls.key --from-file=tls.crt=tls.crt
```
When creating a secret based on a file, the key will default to the basenameof the file, and the value will default to the file content.
I. e. next example works:
```
kubectl create secret generic tls_secret --from-file=tls.key --from-file=tls.crt
```
