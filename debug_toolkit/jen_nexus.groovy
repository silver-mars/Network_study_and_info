node("Linux") {
  stage('Simple test') {
    println('Test access from Jenkins to Nexus, start')
	withCredentials([usernamePassword(credentialsId: 'credId', passwordVariable: 'pass', usernameVariable: 'user')]) {
                  result = sh(script: "curl -ks -u ${user}:${pass} 'https://nexus.ru/repository/maven-distr-release/groupId/artifactId/maven-metadata.xml' -o /dev/null -w '%{http_code}'", returnStatus: true)
                }
    println('Test access from Jenkins to Nexus, end')
 }
}
