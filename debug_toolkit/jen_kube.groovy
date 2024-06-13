NODE_LABEL = ""
pipeline {
   agent {
        node {
            label "${NODE_LABEL}"
        }
    }
    environment {
        kub = tool name: 'kubectl-1.18', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
        ns = ''
        api_sv = ''
        user = ''
    }
    stages{
        stage('Test connection') {
            steps {
                script {
                    println('Test resources in kubernetes, start')
                    withCredentials([string(credentialsId: '', variable: 'secretText')]) {
                                  sh"${env.kub}/kubectl config set-cluster cluster --server=${env.api_sv} --insecure-skip-tls-verify"
                                  sh"${env.kub}/kubectl config set-credentials ${env.user} --token=${secretText}"
                                  sh"${env.kub}/kubectl config set-context ${env.ns} --cluster=cluster --user=${env.user}"
                                  sh"${env.kub}/kubectl config use-context ${env.ns}"
                                  sh"${env.kub}/kubectl api-resources --namespaced=true -o wide"
                        }
                    println('Test resources in kubernetes, end')
                }
            }
        }
    }
}
