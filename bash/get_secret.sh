#!/bin/bash
TOKEN=''
secman_url=''
namespace=''
path=
secret=

curl --request GET \
    --url https://"$secman_url"/v1/"$namespace"/"$path"/roles/"$secret" \
    --header "X-Vault-Token: ${TOKEN}" \
    --header "X-Vault-Namespace: "$namespace"" | jq

