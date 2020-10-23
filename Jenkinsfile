pipeline {
    agent any
    environment {
      PATH = "${PATH}:${getTerraformpath()}"
    }
    stages {
        stage('terraform init - dev') {
            steps {
                sh "terraform init"
                sh "terraform plan"
                sh "terraform apply --auto-approve"
            }
        }
    }
}

def getTerraformpath() {
    def tfHome = tool name: 'terraform-13', type: 'terraform'
    return tfHome
}