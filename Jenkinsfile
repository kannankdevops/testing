pipeline {
  agent any

  environment {
    // Inject your kubeconfig secret (from Jenkins credentials)
    KUBECONFIG_FILE = credentials('kubeconfig-secret') // Set this to your Jenkins secret ID
  }

  stages {
    stage('🛠️ Checkout Code') {
      steps {
        git url: 'https://github.com/your-org/your-k8s-repo.git', branch: 'main'
      }
    }

    stage('🚀 Deploy to Kubernetes') {
      steps {
        script {
          // Use kubectl image and keep it alive during the step using tail
          docker.image('bitnami/kubectl:1.30').inside('--entrypoint=tail -- tail -f /dev/null') {
            withEnv(["KUBECONFIG=${KUBECONFIG_FILE}"]) {
              // Optional sanity check
              sh 'kubectl version --client'
              
              // Apply Kubernetes manifests
              sh 'kubectl apply -f k8s-deploy.yaml'
              
              // (Optional) Check pod status
              sh 'kubectl get pods -n your-namespace'
            }
          }
        }
      }
    }
  }

  post {
    always {
      echo '✅ Pipeline completed.'
    }
    failure {
      echo '❌ Deployment failed.'
    }
  }
}
