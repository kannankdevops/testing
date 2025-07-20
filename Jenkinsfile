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
      image: kkaann/kubectl:1.30.1
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
    KUBECTL_IMAGE = "kkaann/kubectl:1.30.1"
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

    stage('⚙️ Build Custom kubectl Image') {
      steps {
        container('docker') {
          sh '''
            echo "🔨 Building kubectl image..."
            docker build -t ${KUBECTL_IMAGE} -f Dockerfile.kubectl .
            docker push ${KUBECTL_IMAGE}
          '''
        }
      }
    }

    stage('🐳 Build & Push App Image') {
      steps {
        container('docker') {
          withCredentials([usernamePassword(
            credentialsId: 'kkaann',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
          )]) {
            sh '''
              echo "🔐 Logging into DockerHub..."
              echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

              echo "🔧 Building Docker image..."
              export DOCKER_BUILDKIT=1
              docker build -t $IMAGE_NAME .

              echo "📤 Pushing image..."
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
                  echo "📄 Applying ${file}..."
                  kubectl apply -f ${file} -n $K8S_NAMESPACE
                """
              } catch (Exception e) {
                error "❌ Failed to apply ${file}: ${e.getMessage()}"
              }
            }

            sh '''
              echo "🔍 Waiting for deployment rollout..."
              kubectl rollout status deployment/myapp -n $K8S_NAMESPACE --timeout=60s || {
                echo "⚠️ Rollout failed. Debug info:"
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
      echo "✅ Deployment successful: ${IMAGE_NAME} is live in Kubernetes!"
    }
    failure {
      echo "❌ Deployment failed. Please check error logs."
    }
    always {
      cleanWs()
      echo '🧹 Cleaned up workspace.'
    }
  }
}
