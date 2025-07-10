pipeline {
  agent {
    kubernetes {
      inheritFrom 'kubectl-agent'         // Must match your Pod Template name in Jenkins
      defaultContainer 'kubectl'          // Must match container name in Pod Template
    }
  }

  environment {
    // Must match the mount path from Secret volume in Pod Template
    KUBECONFIG = "/home/jenkins/.kube/kubeconfig"
  }

  stages {

    stage('🧾 Checkout Code') {
      steps {
        echo "🔄 Checking out source code..."
        git url: 'https://github.com/kannankdevops/testing.git', branch: 'main'
      }
    }

    stage('🔍 Kubeconfig Sanity Check') {
      steps {
        echo "🔍 Verifying kubectl setup..."
        sh 'kubectl version --client'
        sh 'kubectl config get-contexts'
      }
    }

    stage('🚀 Deploy to Kubernetes') {
      steps {
        echo "🚀 Applying Kubernetes manifests..."
        sh 'kubectl apply -f k8s-deploy.yaml'
      }
    }

    stage('📦 Verify Deployment') {
      steps {
        echo "📦 Getting pod status..."
        sh 'kubectl get pods -n default'  // Replace with your real namespace
      }
    }

  }

  post {
    always {
      echo '✅ Pipeline finished.'
    }
    success {
      echo '🎉 Deployment succeeded!'
    }
    failure {
      echo '❌ Deployment failed. Please check logs above.'
    }
  }
}
