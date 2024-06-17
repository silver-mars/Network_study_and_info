#!/bin/bash

secman_url='' # URL до инстанса secman
namespace='' # tenant Secman
role_id='' # значение поля role id из approle
secret_id='' # значение поля secret id из approle
 
secman_url="$(printf "${secman_url}" | sed -e 's/\/*$//')"
curl -k -s --request 'POST' \
    --url "https://${secman_url}/v1/auth/approle/login" \
    --header "X-Vault-Namespace: ${namespace}" \
    --data "{\"role_id\": \"${role_id}\", \"secret_id\": \"${secret_id}\"}" \
    | jq .auth.client_token

