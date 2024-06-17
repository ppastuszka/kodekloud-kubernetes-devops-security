dockerImageName $(awk 'NR==1 {print $2}' Dockerfile)
echo $dockerImageName

docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy trivy:0.17.2 -q image --severity HIGH --light $dockerImageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy trivy:0.17.2 -q image --severity CRITICAL --light $dockerImageName

exit_code $?
echo "Exit Code: $exit_code"

if [ $exit_code -eq 0 ]; then
    echo "Trivy scan passed successfully"
else
    echo "Trivy scan failed"
    exit 1
fi
