#!/bin/bash

if [ -z ${USER} ]; then
   echo "Missing USER env. Source the env file."
   exit 1
fi

# Openshift service to restart after modifying master-config.yaml
OPENSHIFT_SERVICE="atomic-openshift-master.service"

# Create OS user and add to Admin role
oadm --config=/etc/origin/master/admin.kubeconfig policy add-cluster-role-to-user cluster-admin ${USER}
if [ $? -eq 0 ]; then
    echo "User \"${USER}\" created".
else
    echo "Failed to create \"${USER}\"."
    exit 1
fi

# Set OS Cluster USER password
htpasswd -b /etc/origin/htpasswd ${USER} redhat
if [ $? -ne 0 ]; then
    echo "Failed to set \"${USER}\" cluster password."
    exit 1
fi

oc login --username=${USER} --password=redhat
if [ $? -ne 0 ]; then
    echo "Failed \"${USER}\" cluster login."
    exit 1
fi

oc new-project openshift-infra --display-name="Hawkular Metrics"
if [ $? -ne 0 ]; then
    echo "Failed to create OS project \"openshift-infra\"."
    exit 1
fi

oadm policy add-role-to-user cluster-admin ${USER}
if [ $? -eq 0 ]; then
    echo "Added cluster Admin role for user \"${USER}\"".
else
    echo "Failed to create cluster role for \"${USER}\"."
    exit 1
fi

# Add Hawkular Hostname (metricsPublicURL) to master-config.yaml
./addHawkularHostname.sh
if [ $? -eq 0 ]; then
    echo "Added Hawkular Hostname \"${HAWKULAR_METRICS_HOSTNAME}\" to \"${OPENSHIFT_MASTER_CONFIG}\"."
else
    echo "Failed to add Hawkular Hostname"
    exit 1
fi

# Restart OS Service
echo "Restarting \"${OPENSHIFT_SERVICE}\"."
systemctl restart ${OPENSHIFT_SERVICE}
sleep 5
systemctl status ${OPENSHIFT_SERVICE} | grep "Active: active (running)"
if [ $? -eq 0 ]; then
    echo "Successful restart of \"${OPENSHIFT_SERVICE}\"."
else
    echo "Failed to restart \"${OPENSHIFT_SERVICE}\"."
    exit 1
fi

# Sanity check that oc is responding
oc get pods
if [ $? -ne 0 ]; then
    echo "Failed \"oc get pods\" test."
    exit 1
fi

echo "OS Hawkular Metrics dependencies setup complete."
exit 0
