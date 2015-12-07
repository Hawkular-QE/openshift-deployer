#!/bin/bash

## The purpose of this script is to add the metricsPublicURL to Openshift master-config.yaml

if [ -z ${METRICS_PUBLIC_URL} ]; then
   echo "Missing METRICS_PUBLIC_URL env. Source the env file."
   exit 1
fi

PUBLIC_URL="\ \ metricsPublicURL: ${METRICS_PUBLIC_URL}"

# Backup the masetr-config prior to modifying
cp ${OPENSHIFT_MASTER_CONFIG} ${OPENSHIFT_MASTER_CONFIG}-`date +%s`

grep metricsPublicURL ${OPENSHIFT_MASTER_CONFIG}
if [ $? -eq 0 ]; then
    ## Remove the existing metricsPublicURL, and add new value

    LINE=`awk -v var=metricsPublicURL 'match($0, var){print NR; exit}' ${OPENSHIFT_MASTER_CONFIG}`
    echo "Deleting \"metricsPublicURL\" from \"${OPENSHIFT_MASTER_CONFIG}\"."
    sed -i -e "$LINE"'d' ${OPENSHIFT_MASTER_CONFIG}
else
    ## Determine line number to where metricsPublicURL will be inserted

    LINE=`awk -v var=publicURL 'match($0, var){print NR; exit}' ${OPENSHIFT_MASTER_CONFIG}`
fi

echo "Adding \"${PUBLIC_URL=}\" to \"${OPENSHIFT_MASTER_CONFIG}\"."
sed -i "$LINE i ${PUBLIC_URL}" ${OPENSHIFT_MASTER_CONFIG}

echo "Updated \"${OPENSHIFT_MASTER_CONFIG}\"."
exit 0
