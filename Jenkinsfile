pipeline {
  agent {
    kubernetes {
      label 'myapp-agent'
      defaultContainer 'docker'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: myapp-agent
spec:
  containers:
    - name: docker
      image: docker:24.0
      command: ['cat']
      tty: true
      securityContext:
        privileged: true
      volumeMounts:
        - name: docker-sock
          mountPath: /var/run/docker.sock
    - name: kubectl
      image: lachlanevenson/k8s-kubectl:v1.27.1
      command: ['cat']
      tty: true
      volumeMounts:
        - name: kubeconfig
          mountPath: /root/.kube
  volumes:
    - name: docker-sock
      hostPath:
        path: /var/run/docker.sock
        type: Socket
    - name: kubeconfig
      hostPath:
        path: /root/.kube
        type: Directory
"""
    }
  }

  environment {
    DOCKER_IMAGE = "kkaann/myapp:latest"
    K8S_NAMESPACE = "jenkins"
    KUBECONFIG = "/root/.kube/config"
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/kannankdevops/testing.git'
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        container('docker') {
          withCredentials([usernamePassword(credentialsId: 'kkaann', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh '''
              echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
              docker build -t $DOCKER_IMAGE .
              docker push $DOCKER_IMAGE
            '''
          }
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        container('kubectl') {
          sh '''
            echo "🚀 Deploying to Kubernetes"
            kubectl apply -f myapp-configmap.yaml -n $K8S_NAMESPACE
            kubectl apply -f myapp-deployment.yaml -n $K8S_NAMESPACE
            kubectl apply -f myapp-service.yaml -n $K8S_NAMESPACE
            kubectl apply -f myapp-ingress.yaml -n $K8S_NAMESPACE
          '''
        }
      }
    }
  }

  post {
    success {
      echo "✅ Deployment completed successfully."
    }
    failure {
      echo "❌ Deployment failed! Check logs above."
    }
    always {
      cleanWs()
    }
  }
}
