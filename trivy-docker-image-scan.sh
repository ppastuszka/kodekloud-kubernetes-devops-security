#!/bin/bash

dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo $dockerImageName

docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity HIGH $dockerImageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL $dockerImageName

exit_code $?
echo "Exit Code: $exit_code"

if [ $exit_code -eq 0 ]; then
    echo "Trivy scan passed successfully"
else
    echo "Trivy scan failed"
    exit 1
fi
