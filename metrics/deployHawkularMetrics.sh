#!/bin/bash

if [ -z ${IMAGE_PREFIX} ]; then
   echo "Missing IMAGE_PREFIX env. Source the env file."
   exit 1
fi

ROOT=`pwd`

expect << EOF
    spawn oc login
    expect "Username" { send "$USER\r" }
    expect "Password" { send "redhat\r" }
    expect eof
EOF

# Deploy must be done from within openshift-infra
oc project openshift-infra
if [ $? -ne 0 ]; then
    echo "Failed to make \"openshift-infra\" current project."
    exit 1
fi


# Create Deployer Service account:
oc create -f - <<API
apiVersion: v1
kind: ServiceAccount
metadata:
  name: metrics-deployer
secrets:
- name: metrics-deployer
API

# Heapster user setup
oadm policy add-role-to-user edit system:serviceaccount:openshift-infra:metrics-deployer
oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:openshift-infra:heapster

# Secrets
oc secrets new metrics-deployer nothing=/dev/null

rm -rf origin-metrics
git clone https://github.com/openshift/origin-metrics.git
cd origin-metrics

# Deploy Hawkular Metrics
Echo "Deploying Hawkular Metrics."
oc process -f metrics.yaml -v HAWKULAR_METRICS_HOSTNAME=${HAWKULAR_METRICS_HOSTNAME},IMAGE_PREFIX=${IMAGE_PREFIX},IMAGE_VERSION=${IMAGE_VERSION},USE_PERSISTENT_STORAGE=false,MASTER_URL=${MASTER_URL},REDEPLOY=true | oc create -f -

${ROOT}/isHawkularMetricsRunning.sh
if [ $? -eq 0 ]; then
    echo "Hawkular Metrics Deploy Success."
else
    echo "Hawkular Metrics Deploy Failed."
    exit 1
fi

echo "Hawkular Metrics Deploy complete."
exit 0
