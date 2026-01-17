pipeline {
  agent any

  parameters {
    choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Provision or destroy infrastructure')
    booleanParam(name: 'ENABLE_AMI_BONUS', defaultValue: false, description: 'Create AMI from configured instance (bonus)')
  }

  environment {
    TF_IN_AUTOMATION = "true"
    TF_DIR = "infra"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Install deps') {
      steps {
        sh '''
          set -e
          command -v jq >/dev/null 2>&1 || sudo apt-get update && sudo apt-get install -y jq
          command -v nc >/dev/null 2>&1 || sudo apt-get update && sudo apt-get install -y netcat-openbsd
        '''
      }
    }

    stage('Terraform Init') {
      steps {
        dir(env.TF_DIR) {
          sh 'terraform init -input=false'
          sh 'terraform validate'
        }
      }
    }

    stage('Terraform Apply/Destroy') {
      steps {
        dir(env.TF_DIR) {
          sh '''
            set -e
            if [ "${ACTION}" = "apply" ]; then
              terraform apply -auto-approve -var="enable_ami_bonus=${ENABLE_AMI_BONUS}"
            else
              terraform destroy -auto-approve -var="enable_ami_bonus=${ENABLE_AMI_BONUS}"
            fi
          '''
        }
      }
    }

    stage('Export Outputs') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        sh 'bash scripts/export_outputs.sh infra'
        archiveArtifacts artifacts: 'outputs.json', fingerprint: true
      }
    }

    stage('Validate Reachability') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        sh 'bash scripts/validate_reachability.sh outputs.json'
      }
    }
  }
}

