pipeline {
  agent any

  environment {
    IMAGE_NAME = "kkaann/myapp:latest"
    K8S_NAMESPACE = "mynamespace"
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
          kubectl create namespace $K8S_NAMESPACE || true
          kubectl apply -f myapp-deployment.yaml --namespace=$K8S_NAMESPACE
          kubectl apply -f myapp-service.yaml --namespace=$K8S_NAMESPACE
        '''
      }
    }
  }
}
