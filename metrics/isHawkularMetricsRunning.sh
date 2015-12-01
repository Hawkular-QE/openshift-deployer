#!/bin/bash

PODS=("hawkular-metrics" "hawkular-cassandra" "heapster")
POD_STATE="Running"

seconds=60*15
endTime=$(($(date +%s) + seconds)) # Calc the end time.

for pod in "${PODS[@]}"; do
    echo "Waiting for pod \"${pod}\" to be in \"${POD_STATE}\" state:"
    while [ $(date +%s) -lt $endTime ]; do
        oc get pods | grep ${pod} | grep ${POD_STATE}
        if [ $? -ne 0 ]; then
	    echo -ne "."
            sleep 3
        else
            printf "\nPod \"${pod}\" is in \"${POD_STATE}\" state.\n"
            if [ ${pod} == ${PODS[${#PODS[@]} - 1]} ]; then
		echo "All pods are in \"${POD_STATE}\" state. Exit wait."
		exit 0
	    else
		break
	    fi
        fi
    done
done

echo "Timed out waiting for \"${PODS[@]}\"."
exit 1
