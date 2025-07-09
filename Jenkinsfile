podTemplate(label: 'mypod-template', containers: [
  containerTemplate(
    name: 'jnlp',
    image: 'jenkins/inbound-agent:3107.v665000b_51092-10',
    args: '${computer.jnlpmac} ${computer.name}'
  ),
  containerTemplate(
    name: 'maven',
    image: 'maven:3.8.1-openjdk-11',
    command: 'cat',
    ttyEnabled: true
  )
]) {
  node('mypod-template') {   // 👈 This must match podTemplate's label!
    container('maven') {
      sh 'mvn -version'
    }
  }
}
