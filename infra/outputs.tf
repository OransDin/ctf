output "target_instance_id" {
  value = module.compute.instance_id
}

output "target_public_ip" {
  value = module.compute.public_ip
}

output "target_public_dns" {
  value = module.compute.public_dns
}

output "ssh_command" {
  value = "ssh -i <PATH_TO_KEY.pem> ubuntu@${module.compute.public_ip}"
}

output "ami_id" {
  value = try(module.compute.ami_id, null)
}

output "from_ami_instance_id" {
  value = try(module.compute.from_ami_instance_id, null)
}

