# CTF Infrastructure Project

This repository contains a small CTF infrastructure project.
The purpose of the project is to show how to build a vulnerable environment,
deploy CTFd, and verify that the target is actually reachable.

The focus here is on doing things clearly and correctly, not on adding
unnecessary layers or abstractions.

--------------------------------------------------
What this project does
--------------------------------------------------

- Creates AWS infrastructure using Terraform
- Deploys a vulnerable EC2 instance
- Runs CTFd using Docker Compose
- Adds a simple CTFd plugin that checks connectivity to the target

--------------------------------------------------
Repository structure
--------------------------------------------------

Repository Structure

infra/
- main.tf
- variables.tf
- outputs.tf
- modules/
  - network/
  - compute/

ctfd/
- docker-compose.yml
- plugins/
  - reachability/
    - __init__.py
    - plugin.py

scripts/
- Optional helper scripts

.gitignore
README.txt 

--------------------------------------------------
Infrastructure
--------------------------------------------------

Infrastructure is created with Terraform and deployed on AWS.

It includes:
- Basic networking (VPC, subnets)
- Security groups with limited access
- One EC2 instance that serves as a vulnerable target

Terraform outputs expose the public IP of the EC2 instance.
That output is later used by the CTFd plugin.

--------------------------------------------------
How to deploy the infrastructure
--------------------------------------------------

cd infra
terraform init
terraform apply

After apply completes, Terraform will print the target instance public IP.

--------------------------------------------------
CTFd
--------------------------------------------------

CTFd is run using Docker Compose.

cd ctfd
docker compose up -d

Once running, open a browser and go to:

http://<EC2_PUBLIC_IP>:8000

Create the admin user and complete the basic setup.

--------------------------------------------------
Reachability validation plugin
--------------------------------------------------

A small CTFd plugin is included to verify that the vulnerable EC2 instance
is reachable from the CTFd environment.

What the plugin does:
- Reads the target IP (from Terraform output or AWS)
- Attempts a basic connectivity check (ping)
- Returns success or failure through CTFd

This is meant to prevent situations where a challenge is deployed but the
target is unreachable.

--------------------------------------------------
Security notes
--------------------------------------------------

- Terraform state and .terraform directories are not committed
- Provider binaries are ignored
- No credentials or secrets are stored in the repository

--------------------------------------------------
Notes
--------------------------------------------------

This project is intentionally kept simple.
Every part exists for a reason and can be extended if needed.