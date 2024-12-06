#!/bin/bash
TOKEN=''
vault_url=''
namespace=''
path=
secret=

curl --request GET \
    --url https://"$vault_url"/v1/"$namespace"/"$path"/roles/"$secret" \
    --header "X-Vault-Token: ${TOKEN}" \
    --header "X-Vault-Namespace: "$namespace"" | jq

