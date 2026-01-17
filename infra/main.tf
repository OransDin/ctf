provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "./modules/networking"

  name_prefix  = var.name_prefix
  vpc_cidr     = var.vpc_cidr
  subnet_cidr  = var.subnet_cidr
  allowed_cidr = var.allowed_cidr
}

module "compute" {
  source = "./modules/compute"

  name_prefix         = var.name_prefix
  subnet_id           = module.networking.subnet_id
  security_group_id   = module.networking.security_group_id
  instance_type       = var.instance_type
  key_name            = var.key_name
  ubuntu_ami_ssm_path = var.ubuntu_ami_ssm_path
  enable_ami_bonus    = var.enable_ami_bonus
}
