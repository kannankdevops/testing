pipeline {
  agent {
    kubernetes {
      label 'mypod'
      defaultContainer 'maven'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-agent
spec:
  containers:
  - name: maven
    image: maven:3.8.1-openjdk-11
    command:
    - cat
    tty: true
  - name: git
    image: alpine/git
    command:
    - cat
    tty: true
"""
    }
  }
  stages {
    stage('Clone Code') {
      steps {
        container('git') {
          sh 'git --version'
        }
      }
    }
    stage('Build') {
      steps {
        container('maven') {
          sh 'mvn --version'
        }
      }
    }
  }
}
