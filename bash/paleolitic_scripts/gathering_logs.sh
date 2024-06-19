#!/bin/bash

context=""
namespace=""
pod=""
base_path=$(dirname $(readlink -f "$0"))
limit=100
counter=0
pause=60
while :
    do
        kubectl config use-context "$context"
        pod=$(kubectl -n "$namespace" get po | grep "$pod" | cut -d ' ' -f 1)
        echo "$pod"_"$counter"
        date
        kubectl -n "$namespace" logs "$pod" > "$base_path"/"$pod"_"$counter".log
        let "counter += 1"
        if [ "$counter" -eq "$limit" ]
        then
            break
        else
            sleep "$pause"
        fi
    done
