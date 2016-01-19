#!/bin/bash
oc process -f hawkular-dc-template.yaml | oc create -f -
