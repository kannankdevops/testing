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
      image: bitnami/kubectl:1.27.1-debian-11-r0
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
    githubPush()
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
              export DOCKER_BUILDKIT=1
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
          sh 'kubectl version --client'
          sh '''
            kubectl apply -f myapp-configmap.yaml -n jenkins
            kubectl apply -f myapp-deployment.yaml -n jenkins
            kubectl apply -f myapp-service.yaml -n jenkins
            kubectl apply -f myapp-ingress.yaml -n jenkins
          '''
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
      script {
        try {
          cleanWs()
        } catch (Exception e) {
          echo "⚠️ Could not clean workspace: ${e.message}"
        }
      }
    }
  } // ← THIS was missing
}
