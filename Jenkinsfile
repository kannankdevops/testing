pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: kubectl-agent
spec:
  containers:
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ['cat']
    tty: true
    volumeMounts:
    - name: kubeconfig-volume
      mountPath: /home/jenkins/.kube
    env:
    - name: KUBECONFIG
      value: /home/jenkins/.kube/kubeconfig
  - name: jnlp
    image: jenkins/inbound-agent:latest
    args: ['']
    volumeMounts:
    - name: kubeconfig-volume
      mountPath: /home/jenkins/.kube
    env:
    - name: KUBECONFIG
      value: /home/jenkins/.kube/kubeconfig
  volumes:
  - name: kubeconfig-volume
    secret:
      secretName: kubeconfig-secret
"""
    }
  }
  stages {
    stage('Check kubectl access') {
      steps {
        container('kubectl') {
          sh 'kubectl get pods -n kube-system'
        }
      }
    }
    stage('Deploy App') {
      steps {
        container('kubectl') {
          sh 'kubectl apply -f k8s/deployment.yaml'
        }
      }
    }
  }
}
