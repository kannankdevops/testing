pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker
    image: docker:24.0
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
    }
  }

  environment {
    IMAGE = "kannankdevops/myapp:latest"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        container('docker') {
          sh 'docker build -t $IMAGE .'
        }
      }
    }

    stage('Push to DockerHub') {
      steps {
        container('docker') {
          withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
            sh '''
              echo "$PASS" | docker login -u "$USER" --password-stdin
              docker push $IMAGE
            '''
          }
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        container('docker') {
          sh 'kubectl apply -f myapp-deployment.yaml -n jenkins'
          sh 'kubectl apply -f myapp-service.yaml -n jenkins'
        }
      }
    }
  }
}
