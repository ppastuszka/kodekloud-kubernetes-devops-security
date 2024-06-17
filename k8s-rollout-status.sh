#!/bin/bash

sleep 15s

if [[ $(kubectl -n default rollout status deploy $(deploymentName) --timeout 5s) != *"successfully rolled out"* ]];
then
  echo "Rollout failed"
  kubectl -n default rollout undo deploy $(deploymentName)
  exit 1
else
  echo "Rollout successful"
  exit 0
fi
