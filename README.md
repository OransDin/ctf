# CTF Infrastructure Project

This repository contains a CTF infrastructure project.
The purpose of the project is to show how to build a vulnerable environment,
deploy CTFd, and verify that the target is actually reachable.

The focus here is on doing things clearly and correctly, not on adding
unnecessary layers or abstractions.

--------------------------------------------------
What this project does
--------------------------------------------------

- Provision infrastructure automatically
- Deploy a deliberately vulnerable EC2 instance
- Deploy CTFd as a challenge platform
- Verify that the vulnerable target is reachable and usable
- Control the full infrastructure lifecycle using Jenkins-based automation and Infrastructure as Code

## Quick Start Guide

Follow these steps to deploy the environment from scratch.

### 0. Launch the Management EC2
Provision a single EC2 instance (Ubuntu/Amazon Linux) that will serve as the **Management Server** hosting both Jenkins and CTFd.

### 1. Install Prerequisites
On the Management EC2, perform the following setup:
* **AWS CLI:** Configure credentials (`aws configure`) so Terraform can manage resources.
* **Terraform:** Install the latest version.
* **Docker & Docker Compose:** Required to run the CTFd platform.
* **Jenkins:** Install and ensure the `jenkins` user has permissions to run Docker and Terraform.

### 2. Run the Jenkins Pipeline
1. Create a new **Pipeline Job** in Jenkins.
2. Set **SCM** to Git and point it to this repository.
3. Run the job with the following parameters:
    * `ACTION`: `apply`
    * `USE_AMI_ARTIFACT`: `false` (default) or `true` if using a pre-baked image.
4. **The Pipeline will:**
    * Initialize and run Terraform.
    * Provision the **Vulnerable Target EC2**.
    * Store Terraform outputs (Target IP) as Jenkins artifacts.

### 3. Initialize CTFd (Manual Step)
Since CTFd setup is stateful, the initial configuration is manual:
1. Navigate to: `http://<MANAGEMENT_EC2_PUBLIC_IP>:8000`
2. Complete the setup wizard.
3. Create the administrator account.

### 4. Validate Reachability
Once the infrastructure is up and CTFd is ready:
* Access the **Reachability Plugin** within the CTFd interface.
* Trigger the validation action.
* The system will confirm if the CTFd environment can successfully communicate with the newly provisioned vulnerable target.

### 5. Cleanup
To avoid unnecessary AWS costs, tear down the infrastructure when finished:
* Run the Jenkins job with `ACTION=destroy`.

--------------------------------------------------
High-Level Architecture
--------------------------------------------------
## The system is composed of the following components:
- Git
- Jenkins
- Terraform
- AWS EC2 (Vulnerable Target)
- AWS EC2 (CTFd + Jenkins)
- Bash (user_data)
- CTFd Plugin

--------------------------------------------------
Prerequisites
--------------------------------------------------
Before running the project, the following are required:
- AWS account
- AWS credentials configured on the Jenkins server
- Jenkins installed on a dedicated EC2 instance
- Terraform installed on the Jenkins server
- Docker and Docker Compose installed on the CTFd EC2 instance
- Network access (SSH) to both EC2 instances from your IP
No AWS credentials or secrets are stored in this repository.

--------------------------------------------------
Architectural Decisions
--------------------------------------------------
### Why Jenkins and CTFd Run on Separate EC2 Instances

### Jenkins and CTFd are intentionally deployed on separate EC2 instances.
This decision was made for the following reasons:

1. Separation of concerns- Jenkins is responsible for infrastructure control and automation, while CTFd is an application platform. Combining them would blur responsibilities and complicate maintenance.

2. Security boundaries- Jenkins holds IAM permissions that allow creating and destroying AWS resources. CTFd should not have these permissions or access to Terraform state.

3. Operational independence- Jenkins pipelines may fail, restart, or change frequently. CTFd should remain stable and unaffected by CI/CD activity.

4. Real-world parity- In real environments, CI/CD systems and production platforms are never colocated on the same host.

5. Future extensibility- Either system can be scaled, replaced, or modified independently.

### Why EC2 Small Was Used Instead of Micro:

- EC2 small instances were chosen instead of micro for the following reasons:
- Jenkins, Terraform, Docker, and AWS SDKs can easily exhaust micro instance resources
- Docker Compose and CTFd require stable memory and CPU
- Resource starvation causes misleading failures unrelated to architecture
Using small instances avoids false negatives during testing and evaluation.

### Using Git:
Using Git was a conscious design decision, even though it was not explicitly required by the project instructions.
The main reasons for introducing Git are:

1. Single source of truth- All infrastructure definitions, scripts, and plugins are stored in one place.
This ensures that the environment can always be rebuilt from a known, consistent state.

2. Reproducibility- Anyone cloning the repository can deploy the same environment without relying on undocumented local files or manual steps.

3. Clear separation between code and execution- Git stores what should be built.
Jenkins is responsible only for executing what is defined in the repository.

4. Auditability and reviewability- Changes to infrastructure, vulnerabilities, or validation logic are explicit and reviewable.
This is especially important for CTF environments, where small changes can significantly affect challenge behavior.

Git is therefore used as an enabler, not as a dependency of the project requirements.

--------------------------------------------------
Repository structure
--------------------------------------------------

### Repository Structure

infra/
- main.tf
- variables.tf
- outputs.tf
- modules/
  - network/
	- main.tf
	- variables.tf
	- outputs.tf
  - compute/
	- main.tf
	- variables.tf
	- outputs.tf

ctfd/
- docker-compose.yml
- plugins/
  - reachability/
    - __init__.py
    - plugin.py

scripts/
 - setup_vulnerable_vm.sh
 - validate_vuln.sh
 - export_outputs.sh
 - validate_reachability.sh

.gitignore
README.txt 
--------------------------------------------------
Jenkins Pipeline Flow
--------------------------------------------------
### Jenkins Job Parameters
The Jenkins job supports the following parameters:

- ACTION
	- apply- provision infrastructure
	- destroy- tear down infrastructure
- USE_AMI_ARTIFACT
	- false- provision EC2 using standard Terraform configuration
	- true- deploy EC2 from a prebuilt AMI artifact
- AMI_ID (optional)
	- Used only when USE_AMI_ARTIFACT=true
	- Allows deploying a preconfigured image instead of running user_data

This enables two deployment modes:

- Dynamic vulnerability creation via boot-time scripts
- Prebaked vulnerability via AMI artifact

### Jenkins Execution Flow
When the Jenkins job runs:

1. Repository is cloned from Git

2. Terraform is initialized

3. Terraform is applied or destroyed based on parameters

4. Outputs are generated and stored as artifacts

--------------------------------------------------
Infrastructure Provisioning (Terraform)
--------------------------------------------------

### Infrastructure is created with Terraform and deployed on AWS.

It includes:
- VPC and networking
- Security groups
- Vulnerable EC2 instance
- CTFd EC2 instance

Terraform outputs include:
- Public IP of the vulnerable EC2 instance

Terraform outputs are written to an output file (e.g. outputs.json) and archived as a Jenkins artifact.

--------------------------------------------------
Vulnerability Creation
--------------------------------------------------
### Boot-Time Script
When AMI mode is not used, the vulnerability is created via:
scripts/setup_vulnerable_vm.sh
This script runs automatically during EC2 boot and:
- Creates a dedicated user
- Configures passwordless sudo for a specific binary
- Introduces a controlled privilege escalation vulnerability
- The instance is vulnerable immediately after provisioning.

--------------------------------------------------
CTFd Deployment
--------------------------------------------------

CTFd is deployed manually on a dedicated EC2 instance and is not managed by the Jenkins pipeline.
This separation is intentional.

Deployment Method
On the CTFd EC2 instance:
- Docker is installed manually
- Docker Compose is installed manually
- CTFd is started using Docker Compose
```bash mkdir ctfd && cd ctfd``` ```docker compose up -d ```

Once running, CTFd is available at:
http://<CTFD_EC2_PUBLIC_IP>:8000

After CTFd is started, the initial admin user is created manually through the web interface.

--------------------------------------------------
Reachability validation plugin
--------------------------------------------------

A small CTFd plugin is included to verify that the vulnerable EC2 instance
is reachable from the CTFd environment.

Plugin Input Source
The plugin retrieves the target IP from:
Terraform output artifacts produced by Jenkins
or
AWS EC2 API (fallback)

This ensures the plugin always uses the authoritative infrastructure state.

### Plugin Verification Flow
Retrieve the target EC2 public IP
Perform a TCP-based connectivity check (e.g. port 22)
Return success or failure inside the CTFd interface

A TCP check is used instead of ICMP to avoid false failures due to blocked ping traffic.


--------------------------------------------------
Network and Security Groups
--------------------------------------------------

### Exposed Ports

- Jenkins + CTFd EC2
	- TCP 8000 – CTFd web interface (restricted to operator IP)
	- TCP 22 – SSH (restricted)
	-TCP 8080 - Jenkins port.

- Vulnerable EC2
	- TCP 22 – SSH (restricted)
	- Additional ports may be opened per challenge requirements

No unrestricted public access is allowed.

--------------------------------------------------
Security Notes
--------------------------------------------------
- Terraform state files are not committed
- .terraform directories are ignored
- Provider binaries are ignored
- No credentials or secrets are stored in the repository
- Sensitive values are injected at runtime only

--------------------------------------------------
Final Notes
--------------------------------------------------

This project is intentionally minimal and explicit.
It demonstrates:

- CI/CD-driven infrastructure provisioning
- Controlled vulnerability creation
- Platform isolation and security boundaries
- Automated reachability validation
