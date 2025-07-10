pipeline {
  agent {
    kubernetes {
      inheritFrom 'kubectl-agent'         // This must match the Pod Template name in Jenkins UI
      defaultContainer 'kubectl'          // This is the container name inside your pod template
    }
  }

  environment {
    // KUBECONFIG must match the secret mount path in pod template
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
        echo "🔍 Verifying kubectl access..."
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
        echo "📦 Verifying pod status..."
        sh 'kubectl get pods -n your-namespace' // Replace with actual namespace
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
