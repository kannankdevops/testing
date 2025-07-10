pipeline {
  agent {
    kubernetes {
      inheritFrom 'kubectl-agent'
      defaultContainer 'kubectl'
    }
  }

  environment {
    KUBECONFIG = "/home/jenkins/.kube/kubeconfig"
  }

  stages {
    stage('🛠️ Checkout Code') {
      steps {
        git url: 'https://github.com/kannankdevops/testing.git', branch: 'main'
      }
    }

    stage('🚀 Deploy to Kubernetes') {
      steps {
        sh 'kubectl version --client'
        sh 'kubectl apply -f k8s-deploy.yaml'
        sh 'kubectl get pods -n jenkins'
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
