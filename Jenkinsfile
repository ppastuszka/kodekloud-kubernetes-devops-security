pipeline {
  agent any

  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-service"
    imageName = "pawelpastuszka/public:kodekloud-numeric-app-$GIT_COMMIT"
    appliacationURL = "http://devsecops-poc.polandcentral.cloudapp.azure.com"
    applicationURI = "/increment/99"
  }

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar'
            }
        }
        stage('Unit Tests and Code Coverage') {
            steps {
              sh "mvn test"
            }
        }

        stage('Mutation Tests - PIT') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
        }

        // stage('SonarQube SAST') {
        //     tools {
        //         jdk "jdk17" // the name you have given the JDK installation in Global Tool Configuration
        //     }
        //     steps {
        //       withSonarQubeEnv('SonarQube') {
        //         sh "mvn sonar:sonar \
        //           -Dsonar.projectKey=numeric-application \
        //           -Dsonar.projectName='numeric-application' \
        //           -Dsonar.host.url=http://devsecops-poc.polandcentral.cloudapp.azure.com:9000 \
        //           -Dsonar.login=sonarqube"
        //         }
        //         timeout(time: 2, unit: 'MINUTES') {
        //           script {
        //             waitForQualityGate abortPipeline: true
        //           }
        //         }
        //     }
        //   }

        // stage("Vulnerability Scan - Docker") {
        //     steps {
        //       sh "mvn dependency-check:check"
        //     }
        //     post {
        //       always {
        //         publishDependencyCheck pattern: 'target/dependency-check-report.xml'
        //       }
        //     }
        // }

        stage("Vulnerability Scan - Docker") {
            steps {
              parallel (
                "Trivy Scan": {
                  sh "bash trivy-docker-image-scan.sh"
                },
                "OPA Conftest": {
                  sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy dockerfile-security.rego Dockerfile --all-namespaces'
                }
              )

            }
        }

        stage('Docker Build and Push') {
            steps {
              withDockerRegistry(credentialsId: "docker-hub", url: "") {
                sh 'printenv'
                sh 'sudo docker build -t pawelpastuszka/public:kodekloud-numeric-app-""$GIT_COMMIT"" .'
                sh 'docker push pawelpastuszka/public:kodekloud-numeric-app-""$GIT_COMMIT""'
              }
            }
        }

        stage('Vulnerability Scan - Kubernetes') {
            steps {
              sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s.rego k8s_deployment_service.yaml'
            }
        }

        stage('Kubernetes Deployment - DEV') {
            steps {
              parallel (
                "Deployment": {
                  withKubeConfig([credentialsId: 'kubeconfig']) {
                  sh 'bash k8s-deployment.sh'
                }
                },
                "Rollout Status": {
                  withKubeConfig([credentialsId: 'kubeconfig']) {
                  sh 'bash k8s-rollout-status.sh'
                }
                }
              )
            }
        }
    }
    post {
      always {
        junit 'target/surefire-reports/*.xml'
        jacoco execPattern: 'target/jacoco.exec'
        pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
      }
    }
}
