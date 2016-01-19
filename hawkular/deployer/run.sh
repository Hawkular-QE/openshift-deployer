#!/bin/bash
#
# Copyright 2014-2015 Red Hat, Inc. and/or its affiliates
# and other contributors as indicated by the @author tags.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -ex
TOKEN="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
oc login ${MASTER} --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt --token=${TOKEN}
oc project $PROJECT

oc delete rc ${APP_NAME}
oc delete all --selector app=${APP_NAME}

oc process -f service-template.yaml -v APP_NAME=${APP_NAME} | oc create -f -
oc expose service ${APP_NAME}

# Determine external service name
EXT_SERVICE_NAME=$(oc get route hawkular --template {{.spec.host}})

oc process -f rc-template.yaml \
  -v APP_NAME=${APP_NAME},HAWKULAR_URL=${EXT_SERVICE_NAME} \
  | oc create -f -

oc scale rc ${APP_NAME} --replicas=1
