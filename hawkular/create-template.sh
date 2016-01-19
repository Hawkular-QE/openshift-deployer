#!/bin/bash
oc delete -f hawkular-deployer-template.yaml -n openshift
oc create -f hawkular-deployer-template.yaml -n openshift
