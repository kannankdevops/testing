podTemplate(
    label: 'mypod-template',
    containers: [
        containerTemplate(
            name: 'maven',
            image: 'maven:3.8.1-openjdk-11',
            command: 'cat',
            ttyEnabled: true
        )
    ],
    idleMinutes: 10
) {
    node('mypod-template') {
        container('maven') {
            sh 'echo Hello from Maven container'
        }
    }
}
