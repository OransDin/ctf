pipeline {
  agent any

  parameters {
    choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Provision or destroy infrastructure')
    booleanParam(name: 'ENABLE_AMI_BONUS', defaultValue: false, description: 'Create AMI from configured instance (bonus)')

    string(name: 'KEY_NAME', defaultValue: '', description: 'Existing AWS EC2 Key Pair name (required)')
    string(name: 'ALLOWED_CIDR', defaultValue: '0.0.0.0/0', description: 'CIDR allowed to access SSH/CTFd (recommended: your_public_ip/32)')
  }

  environment {
    TF_IN_AUTOMATION = "true"
    TF_DIR = "infra"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Sanity checks') {
      steps {
        sh '''
          set -e
          if [ -z "${KEY_NAME}" ]; then
            echo "ERROR: KEY_NAME is required (AWS EC2 key pair name)."
            exit 1
          fi
        '''
      }
    }

    stage('Install deps') {
      steps {
        sh '''
          set -e
          if ! command -v jq >/dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install -y jq
          fi
          if ! command -v nc >/dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install -y netcat-openbsd
          fi
        '''
      }
    }

    stage('Terraform Init/Validate') {
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
            TF_VARS="-var=key_name=${KEY_NAME} -var=allowed_cidr=${ALLOWED_CIDR} -var=enable_ami_bonus=${ENABLE_AMI_BONUS}"

            if [ "${ACTION}" = "apply" ]; then
              terraform apply -auto-approve ${TF_VARS}
            else
              terraform destroy -auto-approve ${TF_VARS}
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

    stage('Validate Vulnerability') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        // Optional: only if you want Jenkins to SSH and run validate_vuln.sh remotely
        echo 'Optional stage - will be added after we confirm SSH approach'
      }
    }
  }
}

