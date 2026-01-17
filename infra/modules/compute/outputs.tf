
output "instance_id" {
  value = aws_instance.vulnerable.id
}

output "public_ip" {
  value = aws_instance.vulnerable.public_ip
}

output "public_dns" {
  value = aws_instance.vulnerable.public_dns
}

output "ami_id" {
  value = try(aws_ami_from_instance.ctf_ami[0].id, null)
}

output "from_ami_instance_id" {
  value = try(aws_instance.from_ami[0].id, null)
}

