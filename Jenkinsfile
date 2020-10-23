pipeline {
    agent any
    environment {
      PATH = "${PATH}:${getTerraformpath()}"
    }
    stages {
        stage('terraform init') {
            steps {
                sh "terraform init"
            }
        }
    }
}

def getTerraformpath() {
    def tfHome = tool name: 'terraform-13', type: 'terraform'
    return tfHome
}