#!/bin/bash

## The purpose of this script is to:
##  1) Create required Hawkular Metrics deploy dependencies
##  2) Deploy Hawkular Metrics

./createHawkularDependencies.sh
if [ $? -ne 0 ]; then
    echo "Failed to create Hawkular Metrics dependencies."
    exit 1
fi

./deployHawkularMetrics.sh
if [ $? -ne 0 ]; then
    echo "Failed Hawkular Metrics deploy."
    exit 1
fi

exit 0



