pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker
    image: kkaann/docker-kubectl:latest   # ✅ use your updated image
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
    IMAGE = "kkaann/myapp:latest"
    KUBE_NAMESPACE = "jenkins"
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
          withCredentials([usernamePassword(credentialsId: 'kkaann', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh '''
              echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
              docker push $IMAGE
            '''
          }
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        container('docker') {
          sh 'kubectl version --client'  // ✅ Test kubectl works
          sh 'kubectl apply -f myapp-deployment.yaml -n $KUBE_NAMESPACE'
          sh 'kubectl apply -f myapp-service.yaml -n $KUBE_NAMESPACE'
        }
      }
    }
  }

  post {
    failure {
      echo "❌ Pipeline failed!"
    }
    success {
      echo "✅ Deployment successful!"
    }
  }
}
