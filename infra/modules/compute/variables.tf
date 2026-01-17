variable "name_prefix" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type = string
}

variable "ubuntu_ami_ssm_path" {
  type    = string
  default = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

variable "enable_ami_bonus" {
  type    = bool
  default = false
}

