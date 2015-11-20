# Back out Hawkular Metrics pods / projecdt

oc delete all --selector=metrics-infra
oc delete secrets --selector=metrics-infra
oc delete sa --selector=metrics-infra
oc delete ServiceAccount metrics-deployer
oc delete secret metrics-deployer
oc delete project openshift-infra
