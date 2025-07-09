pipeline {
  agent any

  environment {
    IMAGE_NAME = "kkaann/myapp:latest"
  }

  stages {
    stage('Build Docker Image') {
      steps {
        sh 'docker build -t myapp .'
      }
    }

    stage('Push to DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'kkaann', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker tag myapp "$DOCKER_USER/myapp:latest"
            docker push "$DOCKER_USER/myapp:latest"
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh '''
          kubectl apply -f k8s-deploy/deployment.yaml
          kubectl apply -f k8s-deploy/service.yaml
        '''
      }
    }
  }
}
