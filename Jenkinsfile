pipeline {
  agent any

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
              sh "bash trivy-docker-image-scan.sh"
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

        stage('Kubernetes Deployment - DEV') {
            steps {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "sed -i 's#replace#pawelpastuszka/public:kodekloud-numeric-app-$GIT_COMMIT#g' k8s_deployment_service.yaml"
                sh 'kubectl apply -f k8s_deployment_service.yaml'
              }
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
