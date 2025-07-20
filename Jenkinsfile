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
    - name: node
      image: node:18-alpine
      command: ["/bin/sh"]
      args: ["-c", "cat"]
      tty: true
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
      image: bitnami/kubectl:1.32
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
    DOCKER_IMAGE = "kkaann/myapp"
    DOCKER_TAG = "${env.BUILD_NUMBER}"
    DOCKER_CREDENTIALS_ID = 'dockerhub-creds'
    KUBECONFIG_FILE = credentials('kubeconfig') // You must define this in Jenkins
    K8S_NAMESPACE = "jenkins"
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
          sh 'npm run build || echo "No build step defined."'
        }
      }
    }

    stage('🐳 Build Docker Image') {
      steps {
        container('docker') {
          sh '''
            docker version
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
            credentialsId: "$DOCKER_CREDENTIALS_ID",
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
          )]) {
            sh '''
              echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
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
      withEnv(["KUBECONFIG=$KUBECONFIG_FILE"]) {
        sh '''
          echo "🔍 DEBUG: Current User: $(whoami)"
          echo "🔍 DEBUG: Current Directory: $(pwd)"
          echo "🔍 DEBUG: List Files:"
          ls -alh

          echo "🔍 DEBUG: Check if KUBECONFIG exists and is readable"
          if [ ! -f "$KUBECONFIG" ]; then
            echo "❌ KUBECONFIG file not found at $KUBECONFIG"
            exit 1
          fi

          echo "🔍 DEBUG: Show Kubernetes Context"
          kubectl config current-context || exit 1

          echo "📄 Applying Kubernetes Manifests..."
          for file in *.yaml; do
            echo "📄 Applying $file..."
            kubectl apply -f "$file" -n $K8S_NAMESPACE || exit 1
          done

          echo "⏳ Waiting for Deployment Rollout..."
          kubectl rollout status deployment/myapp -n $K8S_NAMESPACE || exit 1
        '''
      }
    }
  }
}


  post {
    success {
      echo "✅ Deployment of $DOCKER_IMAGE:$DOCKER_TAG completed successfully!"
    }
    failure {
      echo "❌ Pipeline failed. Please check the logs above."
    }
    always {
      cleanWs()
    }
  }
}
