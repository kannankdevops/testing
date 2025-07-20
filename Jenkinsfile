pipeline {
  agent {
    kubernetes {
      label 'myapp-agent'
      defaultContainer 'docker'
      yaml """
apiVersion: v1
kind: Pod
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
      image: bitnami/kubectl:1.27.1-debian-11-r0
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
    KUBECONFIG = "/root/.kube/config"
    K8S_NAMESPACE = "jenkins"
  }

  triggers {
    githubPush()
  }

  stages {
    stage('📥 Checkout Code') {
      steps {
        git branch: 'main', url: 'https://github.com/kannankdevops/testing.git'
      }
    }

    stage('🐳 Build & Push Docker Image') {
      steps {
        container('docker') {
          withCredentials([usernamePassword(
            credentialsId: 'kkaann',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
          )]) {
            sh '''
              echo "🔐 Logging in to DockerHub..."
              echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

              echo "🔧 Building Docker image with BuildKit..."
              export DOCKER_BUILDKIT=1
              docker build -t $DOCKER_IMAGE .

              echo "📤 Pushing image to DockerHub..."
              docker push $DOCKER_IMAGE
            '''
          }
        }
      }
    }

    stage('🚀 Deploy to Kubernetes') {
      steps {
        container('kubectl') {
          script {
            def manifestFiles = [
              'myapp-configmap.yaml',
              'myapp-deployment.yaml',
              'myapp-service.yaml',
              'myapp-ingress.yaml'
            ]

            for (file in manifestFiles) {
              try {
                sh """
                  echo "📄 Applying $file..."
                  kubectl apply -f $file -n $K8S_NAMESPACE
                """
              } catch (Exception e) {
                error "❌ Failed to apply $file: ${e.getMessage()}"
              }
            }
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Deployment completed successfully."
    }
    failure {
      echo "❌ Deployment failed. Check above for specific manifest errors."
    }
    always {
      script {
        try {
          echo "🧹 Cleaning up workspace..."
          cleanWs()
        } catch (err) {
          echo "⚠️ Failed to clean workspace: ${err.message}"
        }
      }
    }
  }
}
