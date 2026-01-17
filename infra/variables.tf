variable "aws_region" {
  type    = string
  default = "il-central-1"
}

variable "name_prefix" {
  type    = string
  default = "ctf"
}

variable "vpc_cidr" {
  type    = string
  default = "10.50.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.50.1.0/24"
}

# IMPORTANT: set this to YOUR public IP /32 for safety
variable "allowed_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

# Use an existing EC2 key pair name (created in AWS console or via terraform)
variable "key_name" {
  type = string
}

# Ubuntu 22.04 LTS (Jammy) official SSM parameter for x86_64
variable "ubuntu_ami_ssm_path" {
  type    = string
  default = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

variable "enable_ami_bonus" {
  type    = bool
  default = false
}

