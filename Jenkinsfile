pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
spec:
  containers:
    - name: docker
      image: docker:24.0.7
      command: ['cat']
      tty: true
      volumeMounts:
        - name: docker-sock
          mountPath: /var/run/docker.sock

    - name: node
      image: node:18-alpine
      command: ['cat']
      tty: true

    - name: kubectl
      image: bitnami/kubectl:1.32
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
      secret:
        secretName: kubeconfig-secret
"""
    }
  }

  environment {
    DOCKER_IMAGE = "kkaann/myapp"
    DOCKER_TAG = "${env.BUILD_NUMBER}"
    K8S_NAMESPACE = "jenkins"
    KUBECONFIG = "/root/.kube/config"
  }

  stages {
    stage('📥 Checkout Code') {
      steps {
        container('node') {
          git branch: 'main', url: 'https://github.com/kannankdevops/testing.git'
        }
      }
    }

    stage('📦 Install Dependencies') {
      steps {
        container('node') {
          sh 'npm install'
          sh 'npm run build || echo "No build script defined."'
        }
      }
    }

    stage('🐳 Build Docker Image') {
      steps {
        container('docker') {
          sh '''
            echo "[INFO] Docker Version:"
            docker version

            echo "[INFO] Building Docker Image..."
            export DOCKER_BUILDKIT=1
            docker build -t $DOCKER_IMAGE:$DOCKER_TAG .
            docker tag $DOCKER_IMAGE:$DOCKER_TAG $DOCKER_IMAGE:latest
          '''
        }
      }
    }

    stage('📤 Push Docker Image') {
      steps {
        container('docker') {
          withCredentials([usernamePassword(
            credentialsId: 'dockerhub-creds',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
          )]) {
            sh '''
              echo "[INFO] Logging in to Docker Hub..."
              echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

              echo "[INFO] Pushing Docker Image..."
              docker push $DOCKER_IMAGE:$DOCKER_TAG
              docker push $DOCKER_IMAGE:latest
            '''
          }
        }
      }
    }

    stage('🚀 Deploy to Kubernetes') {
      steps {
        container('kubectl') {
          withCredentials([file(credentialsId: 'kubeconfig-secret', variable: 'KUBECONFIG')]) {
            sh '''
              echo "🔍 Using Kubeconfig: $KUBECONFIG"
              kubectl config get-contexts
              kubectl config current-context || exit 1

              echo "📄 Applying YAML manifests..."
              for file in *.yaml; do
                echo "➡️ Applying $file"
                kubectl apply -f "$file" -n $K8S_NAMESPACE || exit 1
              done

              echo "⏳ Waiting for Deployment rollout..."
              if ! kubectl rollout status deployment/myapp -n $K8S_NAMESPACE --timeout=60s; then
                echo "❌ Rollout failed. Collecting debug info..."

                echo "🔍 Deployment YAML:"
                kubectl get deployment myapp -n $K8S_NAMESPACE -o yaml || true

                echo "🔍 Pods:"
                kubectl get pods -n $K8S_NAMESPACE -o wide || true

                echo "🔍 Pod Logs:"
                for pod in $(kubectl get pods -n $K8S_NAMESPACE -l app=myapp -o jsonpath='{.items[*].metadata.name}'); do
                  echo "📄 Logs for $pod"
                  kubectl logs "$pod" -n $K8S_NAMESPACE --tail=100 || true
                done

                echo "🔍 Events:"
                kubectl get events -n $K8S_NAMESPACE --sort-by=.metadata.creationTimestamp || true

                exit 1
              fi
            '''
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Deployment of ${DOCKER_IMAGE}:${DOCKER_TAG} succeeded!"
    }
    failure {
      echo "❌ Pipeline failed. See logs and Kubernetes debug output above."
    }
    always {
      cleanWs()
    }
  }
}
