#!/bin/bash

base_path=$(dirname $(readlink -f "$0"))
pause_b=100
counter=0
while :
    do
        ssh dhub kubectl config use-context prod-kuber
        pod=$(ssh dhub kubectl -n lc-egais get po | grep api-lc-license | cut -d ' ' -f 1)
        echo "$pod""_$counter"
        date
        ssh dhub kubectl -n lc-egais logs $pod > "$base_path"/api-lc_license_$counter.log
        let "counter += 1"
        if [ $counter -eq $pause_b ]
        then
            break
        else
            sleep 60
        fi
    done
