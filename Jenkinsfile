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
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        }

        stage('Docker Build and Push') {
            steps {
              withDockerRegistry(credentialsId: "docker-hub") {
                sh 'printenv'
                sh 'docker build -t pawelpastuszka/public:kodekloud-numeric-app-""$GIT_COMMIT"" .'
                sh 'docker push pawelpastuszka/public:kodekloud-numeric-app-""$GIT_COMMIT""'
              }
            }
        }
    }
}