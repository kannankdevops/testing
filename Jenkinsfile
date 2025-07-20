pipeline {
  agent {
    kubernetes {
      label 'myapp-agent'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: docker
      image: docker:24.0
      command: ['cat']
      tty: true
      volumeMounts:
        - name: docker-sock
          mountPath: /var/run/docker.sock
    - name: kubectl
      image: lachlanevenson/k8s-kubectl:v1.27.1
      command: ['cat']
      tty: true
  volumes:
    - name: docker-sock
      hostPath:
        path: /var/run/docker.sock
"""
    }
  }

  environment {
    DOCKER_IMAGE = "kkaann/myapp:latest"
  }

  triggers {
    githubPush()  // Make sure webhook is configured correctly in GitHub
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
            sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
            sh 'docker build -t $DOCKER_IMAGE .'
            sh 'docker push $DOCKER_IMAGE'
          }
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        container('kubectl') {
          // Optional: Validate kubectl context
          sh 'kubectl version --client'
          sh 'kubectl config get-contexts'

          // Updated paths: all YAMLs are in repo root
          sh 'kubectl apply -f myapp-configmap.yaml -n jenkins'
          sh 'kubectl apply -f myapp-deployment.yaml -n jenkins'
          sh 'kubectl apply -f myapp-service.yaml -n jenkins'
          sh 'kubectl apply -f myapp-ingress.yaml -n jenkins'
        }
      }
    }
  }

  post {
    success {
      echo "✅ Deployment complete"
    }
    failure {
      echo "❌ Deployment failed"
    }
    always {
      cleanWs()
    }
  }
}
