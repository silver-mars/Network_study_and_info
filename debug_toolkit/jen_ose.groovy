NODE_LABEL = ""
pipeline {
   agent {
        node {
            label "${NODE_LABEL}"
        }
    }
    environment {
        OC = tool name: 'oc-4.5.0', type: 'oc'
        api_sv = ''
        ns = ''
    }
    stages{
        stage('Test connection to Openshift') {
            steps {
                script {
                    println('Test access to resources in openshift, start')
                    withCredentials([string(credentialsId: 'jenkins_sa_token', variable: 'secretText')]) {
                                  result = sh"echo ${secretText}"
                                  sh"oc login --token=${secretText} --server=${env.api_sv}"
                                  sh"${env.OC}/oc config set-context --current --namespace={env.ns}"
                                  sh"${env.OC}/oc api-resources --namespaced=true -o wide"
                        }
                    println('Test access to resources in openshift, end')
                }
            }
        }
    }
}
