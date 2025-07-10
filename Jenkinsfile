pipeline {
  agent {
    kubernetes {
      label 'kubectl'         // must match the label you gave in the pod template
      defaultContainer 'kubectl'  // match the container name you defined
    }
  }

  environment {
    KUBECONFIG = "/home/jenkins/.kube/kubeconfig"  // matches what you set in Env and Volume
  }

  stages {
    stage('🛠️ Checkout Code') {
      steps {
        git url: 'https://github.com/your-org/your-k8s-repo.git', branch: 'main'
      }
    }

    stage('🚀 Deploy to Kubernetes') {
      steps {
        sh 'kubectl version --client'
        sh 'kubectl apply -f k8s-deploy.yaml'
        sh 'kubectl get pods -n your-namespace'
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
