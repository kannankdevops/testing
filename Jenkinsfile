pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: jnlp
    image: jenkins/inbound-agent
    args: ['\$(JENKINS_SECRET)', '\$(JENKINS_NAME)']
  - name: alpine
    image: alpine
    command:
    - cat
    tty: true
"""
    }
  }

  stages {
    stage('Check JNLP Agent') {
      steps {
        sh 'echo Hello from Jenkins jnlp agent!'
        sh 'whoami'
        sh 'hostname'
      }
    }

    stage('Alpine Container') {
      steps {
        container('alpine') {
          sh 'echo Running inside alpine container!'
          sh 'apk add --no-cache curl'
          sh 'curl https://ifconfig.me'
        }
      }
    }
  }
}
