pipeline {
  agent {
    kubernetes {
      label 'jenkins-k8s-agent'
      defaultContainer 'docker'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins-k8s-agent
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
      image: bitnami/kubectl:1.29
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
    DOCKER_IMAGE = "kkaann/myapp"
    TAG = "latest"
    IMAGE_NAME = "${DOCKER_IMAGE}:${TAG}"
    K8S_NAMESPACE = "jenkins"
    KUBECONFIG = "/root/.kube/config"
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
            credentialsId: 'kkaann', // DockerHub credentials ID
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
          )]) {
            sh '''
              echo "🔐 Logging into DockerHub..."
              echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

              echo "🔧 Building Docker image with BuildKit..."
              export DOCKER_BUILDKIT=1
              docker build -t $IMAGE_NAME .

              echo "📤 Pushing image to DockerHub..."
              docker push $IMAGE_NAME
            '''
          }
        }
      }
    }

    stage('🚀 Deploy to Kubernetes') {
      steps {
        container('kubectl') {
          script {
            def manifests = [
              'myapp-configmap.yaml',
              'myapp-deployment.yaml',
              'myapp-service.yaml',
              'myapp-ingress.yaml'
            ]

            for (file in manifests) {
              try {
                sh """
                  echo "📄 Applying manifest: ${file}"
                  kubectl apply -f ${file} -n $K8S_NAMESPACE
                """
              } catch (Exception e) {
                error "❌ Failed to apply ${file}: ${e.getMessage()}"
              }
            }

            sh '''
              echo "🔍 Verifying deployment status..."
              kubectl rollout status deployment/myapp -n $K8S_NAMESPACE --timeout=60s || {
                echo "⚠️ Rollout failed. Debug info below:"
                kubectl get all -n $K8S_NAMESPACE
                kubectl describe deployment myapp -n $K8S_NAMESPACE || true
                exit 1
              }
            '''
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Pipeline completed successfully. ${IMAGE_NAME} is deployed to Kubernetes."
    }
    failure {
      echo "❌ Pipeline failed. Please check the logs above for details."
    }
    always {
      cleanWs()
      echo '🧹 Workspace cleaned.'
    }
  }
}
