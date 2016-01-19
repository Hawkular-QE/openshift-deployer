#!/bin/bash
oc delete dc hawkular
oc delete services hawkular
oc delete route hawkular
oc delete is hawkular
oc delete rc hawkular
