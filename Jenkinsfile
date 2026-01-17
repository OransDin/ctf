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
    // Optional safety: prevents AWS SDK from trying IMDS when creds exist
    AWS_EC2_METADATA_DISABLED = "true"
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
            echo "ERROR: KEY_NAME is required (AWS EC2 Key Pair name)."
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
          if ! command -v docker >/dev/null 2>&1; then
            echo "ERROR: docker is not installed on this Jenkins node."
            exit 1
          fi
          docker compose version >/dev/null 2>&1 || {
            echo "ERROR: docker compose plugin is missing."
            exit 1
          }
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

    stage('Prepare CTFd Data') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        sh '''
          set -e
          mkdir -p ctfd/data
          cp outputs.json ctfd/data/outputs.json
          echo "[+] Copied outputs.json to ctfd/data/outputs.json"
        '''
      }
    }

    stage('Run CTFd with Plugin') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        dir('ctfd') {
          sh '''
            set -e
            docker compose down || true
            docker compose pull
            docker compose up -d
            docker compose ps
          '''
        }
      }
    }

    stage('Validate Vulnerability') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        echo 'Vulnerability validation is documented in README and can be executed on the target instance.'
      }
    }
  }
}

