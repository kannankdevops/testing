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
      resources:
        requests:
          cpu: 100m
          memory: 256Mi

    - name: kubectl
      image: bitnami/kubectl:1.30.1
      command: ['cat']
      tty: true
      env:
        - name: KUBECONFIG
          value: /kubeconfig/config
      volumeMounts:
        - name: kubeconfig
          mountPath: /kubeconfig
          readOnly: true

  volumes:
    - name: kubeconfig
      secret:
        secretName: kubeconfig  # 👈 Must match the ID of your secret file credential in Jenkins
"""
    }
  }

  environment {
    DOCKER_IMAGE = "kkaann/myapp"
    TAG = "latest"
    IMAGE_NAME = "${DOCKER_IMAGE}:${TAG}"
    K8S_NAMESPACE = "jenkins"
    KUBECONFIG = "/kubeconfig/config"
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
              echo "🔐 Logging into DockerHub..."
              echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

              echo "🔧 Building Docker image..."
              export DOCKER_BUILDKIT=1
              docker build -t $IMAGE_NAME .

              echo "📤 Pushing Docker image..."
              docker push $IMAGE_NAME
            '''
          }
        }
      }
    }

    stage('🚀 Apply Kubernetes Manifests') {
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
              sh "echo '📄 Applying ${file}...' && kubectl apply -f ${file} -n ${K8S_NAMESPACE}"
            }

            sh '''
              echo "🔍 Checking rollout..."
              kubectl rollout status deployment/myapp -n ${K8S_NAMESPACE} --timeout=60s || {
                echo "⚠️ Rollout failed. Debugging info:"
                kubectl describe deployment myapp -n ${K8S_NAMESPACE}
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
      echo "✅ Application deployed: ${IMAGE_NAME}"
    }
    failure {
      echo "❌ Deployment failed. See logs for details."
    }
    always {
      cleanWs()
      echo "🧹 Workspace cleaned."
    }
  }
}
