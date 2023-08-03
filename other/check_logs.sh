#!/bin/bash

TOKEN=""
CHAT_ID=""

contur=test-kuber
contur=prod-kuber
namespace=svs-test
namespace=svs-prod
seek=front-filter
base_path=$(dirname $(readlink -f "$0"))

ssh dhub kubectl config use-context $contur
pod=$(ssh dhub kubectl -n $namespace get po | grep $seek | cut -d ' ' -f 1)
echo checking logs into "$pod" ...
date
if ssh dhub kubectl -n $namespace logs $pod | grep -E "ERROR|FATAL" | grep -Evq "090000999999|router" # if result command = 0
    then # true
        echo "errors detected"
        echo "gathering logs.."
        ssh dhub kubectl -n $namespace logs $pod > "$base_path"/"$seek".log
        message="Вижу ошибки, босс"
        curl -s -X POST https://api.telegram.org/bot$TOKEN/sendMessage -d chat_id=$CHAT_ID -d text="$message" > /dev/null
        message=$(grep -E "ERROR|WARN|FATAL" "$base_path"/"$seek".log)
        curl -s -X POST https://api.telegram.org/bot$TOKEN/sendMessage -d chat_id=$CHAT_ID -d text="$message" > /dev/null
    else # if result command = 1
        echo "all clear"
        #message="В секторе "$contur" всё чисто, босс."
        #curl -s -X POST https://api.telegram.org/bot$TOKEN/sendMessage -d chat_id=$CHAT_ID -d text="$message" > /dev/null
fi
