#!/bin/bash

login=''
secman_url=''
path_to_secret=''
namespace=''
pass=''

curl -s --request POST \
  --url https://"$secman_url"/v1/auth/ad/"$path_to_secret"/login/"$login" \
  --header 'Content-Type: application/json' \
  --header "X-Vault-Namespace: "$namespace"" \
  --data "{\"password\": \""${pass}"\"}" | jq

