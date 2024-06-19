#!/bin/bash

TOKEN=""
CHAT_ID=""

contur="your context is here"
namespace=""
seek="pod_name"
# Складывать логи ошибок будем по пути, где располагается скрипт
base_path=$(dirname $(readlink -f "$0"))

kubectl config use-context "$contur"
pod=$(kubectl -n "$namespace" get po | grep "$seek" | cut -d ' ' -f 1)
echo Checking logs into "$pod" ...
date
if kubectl -n "$namespace" logs "$pod" | grep -Eq "ERROR|FATAL" # if result command = 0
    then # true
        echo "Errors detected"
        echo "Gathering logs.."
        kubectl -n "$namespace" logs "$pod" > "$base_path"/"$seek".log
        message="Вижу ошибки, босс"
        curl -s -X POST https://api.telegram.org/bot"$TOKEN"/sendMessage -d chat_id="$CHAT_ID" -d text="$message" > /dev/null
        message=$(grep -E "ERROR|WARN|FATAL" "$base_path"/"$seek".log)
        curl -s -X POST https://api.telegram.org/bot"$TOKEN"/sendMessage -d chat_id="$CHAT_ID" -d text="$message" > /dev/null
    else # if result command = 1
        echo "all clear"
        message="В секторе "$contur" всё чисто, босс."
        curl -s -X POST https://api.telegram.org/bot"$TOKEN"/sendMessage -d chat_id="$CHAT_ID" -d text="$message" > /dev/null
fi
