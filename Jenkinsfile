pipeline {
  agent {
    kubernetes {
      label 'myapp-agent'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: kubectl
      image: kkaann/docker-kubectl:latest
      command: ['cat']
      tty: true
    - name: docker
      image: docker:24.0
      command: ['cat']
      tty: true
      volumeMounts:
        - name: docker-sock
          mountPath: /var/run/docker.sock
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

  stages {
    stage('Checkout') {
      steps {
        // ✅ Checkout from the main branch explicitly
        git branch: 'main',
            url: 'https://github.com/kannankdevops/testing.git'
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        container('docker') {
          // ✅ Make sure you're in the correct directory
          sh 'docker build -t $DOCKER_IMAGE .'
          sh 'docker push $DOCKER_IMAGE'
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        container('kubectl') {
          // ✅ Ensure these YAML files exist in your Git repo
          sh 'kubectl apply -f myapp-deployment.yaml -n jenkins'
          sh 'kubectl apply -f myapp-service.yaml -n jenkins'
        }
      }
    }
  }
}
