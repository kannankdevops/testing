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
      image: docker:24.0-cli
      command: ["/bin/sh"]
      args: ["-c", "cat"]
      tty: true
      securityContext:
        privileged: true
      volumeMounts:
        - name: docker-sock
          mountPath: /var/run/docker.sock

    - name: kubectl
      image: bitnami/kubectl:1.27.1
      command: ["/bin/sh"]
      args: ["-c", "cat"]
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
    IMAGE_NAME = "kkaann/myapp:latest"
    K8S_NAMESPACE = "jenkins"
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
            credentialsId: 'dockerhub-creds',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
          )]) {
            sh '''
              echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
              export DOCKER_BUILDKIT=1
              docker build -t $IMAGE_NAME .
              docker push $IMAGE_NAME
            '''
          }
        }
      }
    }

    stage('🚀 Deploy to Kubernetes') {
      steps {
        container('kubectl') {
          withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
            sh '''
              echo "Shell check:"
              ls -l /bin/sh
              which sh || echo "No sh found"

              echo "🛠️ Preparing kubeconfig"
              mkdir -p ~/.kube
              cp $KUBECONFIG_FILE ~/.kube/config
              chmod 600 ~/.kube/config

              echo "🔍 kubectl version:"
              kubectl version --client

              echo "📄 Applying all YAML manifests..."
              for file in *.yaml; do
                echo "📄 Applying $file"
                kubectl apply -f "$file" -n $K8S_NAMESPACE
              done

              echo "⏳ Waiting for rollout..."
              kubectl rollout status deployment/myapp -n $K8S_NAMESPACE
            '''
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
      echo "❌ Deployment failed. Please check logs."
    }
    always {
      cleanWs()
    }
  }
}
