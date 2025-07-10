pipeline {
  agent any

  environment {
    IMAGE = 'kkaann/myapp:latest'
  }

  stages {
    stage('🔨 Build Docker Image') {
      steps {
        sh 'docker build -t myapp .'
      }
    }

    stage('📤 Push to DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'kkaann', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker tag myapp "$IMAGE"
            docker push "$IMAGE"
          '''
        }
      }
    }

    stage('🚀 Deploy to Kubernetes') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
          script {
            docker.image('bitnami/kubectl:1.30').inside('--entrypoint=sh') {
              sh '''
                export KUBECONFIG=$KUBECONFIG_FILE
                echo "Deploying to Kubernetes..."
                kubectl apply -f k8s-deploy/myapp-deployment.yaml
                kubectl apply -f k8s-deploy/myapp-service.yaml
              '''
            }
          }
        }
      }
    }

    stage('🔍 Optional Sanity Check') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
          script {
            docker.image('bitnami/kubectl:1.30').inside('--entrypoint=sh') {
              sh '''
                export KUBECONFIG=$KUBECONFIG_FILE
                echo "Waiting 10s before checking pod status..."
                sleep 10
                kubectl get pods -n default
              '''
            }
          }
        }
      }
    }
  }
}
