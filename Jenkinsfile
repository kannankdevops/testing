// 📦 Start of Jenkins Pipeline
pipeline {
  agent any  // 💻 Use any available Jenkins agent to run the pipeline

  environment {
    // 🌍 Set the Docker image name to be used globally in this pipeline
    IMAGE = 'kkaann/myapp:latest'
  }

  stages {
    // 🚧 Stage 1: Build the Docker Image
    stage('Build Docker Image') {
      steps {
        // 🛠️ Build the Docker image from the Dockerfile in current directory
        sh 'docker build -t myapp .'
      }
    }

    // 🚀 Stage 2: Push the Docker Image to DockerHub
    stage('Push to DockerHub') {
      steps {
        // 🔐 Use Jenkins credentials to authenticate with DockerHub
        withCredentials([usernamePassword(
          credentialsId: 'kkaann', 
          usernameVariable: 'DOCKER_USER', 
          passwordVariable: 'DOCKER_PASS'
        )]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin  # 🔐 Docker login
            docker tag myapp "$IMAGE"  # 🏷️ Tag the image
            docker push "$IMAGE"       # 📤 Push the image to DockerHub
          '''
        }
      }
    }

    // ☸️ Stage 3: Deploy the Application to Kubernetes
    stage('Deploy to Kubernetes') {
      steps {
        // 🔐 Inject the kubeconfig file stored in Jenkins credentials
        withCredentials([file(
          credentialsId: 'kubeconfig', 
          variable: 'KUBECONFIG_FILE'
        )]) {
          // 🐳 Use Docker container to run kubectl inside Jenkins
          withDockerContainer(
            image: 'bitnami/kubectl:1.30', 
            args: '--entrypoint=sh'
          ) {
            sh '''
              export KUBECONFIG=$KUBECONFIG_FILE  # 📁 Set kubeconfig path
              echo "Deploying to Kubernetes..."
              kubectl apply -f k8s-deploy/myapp-deployment.yaml  # 🚀 Deploy Deployment
              kubectl apply -f k8s-deploy/myapp-service.yaml     # 🌐 Deploy Service
            '''
          }
        }
      }
    }

    // ✅ Stage 4: Optional Sanity Check on Kubernetes
    stage('Optional Sanity Check') {
      steps {
        // 🔐 Reuse kubeconfig credentials
        withCredentials([file(
          credentialsId: 'kubeconfig', 
          variable: 'KUBECONFIG_FILE'
        )]) {
          withDockerContainer(
            image: 'bitnami/kubectl:1.30', 
            args: '--entrypoint=sh'
          ) {
            sh '''
              export KUBECONFIG=$KUBECONFIG_FILE
              echo "Waiting 10s before checking pod status..."  # ⏳ Allow time for pods to start
              sleep 10
              kubectl get pods -n default  # 📋 List running pods in default namespace
            '''
          }
        }
      }
    }
  }
}
