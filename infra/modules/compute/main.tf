data "aws_ssm_parameter" "ubuntu_ami" {
  name = var.ubuntu_ami_ssm_path
}

locals {
  setup_script = file("${path.module}/../../../scripts/setup_vulnerable_vm.sh")
}

resource "aws_instance" "vulnerable" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = local.setup_script

  tags = {
    Name = "CTF-Vulnerable-Target"
  }
}

resource "aws_ami_from_instance" "ctf_ami" {
  count              = var.enable_ami_bonus ? 1 : 0
  name               = "${var.name_prefix}-vuln-ami-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  source_instance_id = aws_instance.vulnerable.id
}

resource "aws_instance" "from_ami" {
  count                       = var.enable_ami_bonus ? 1 : 0
  ami                         = aws_ami_from_instance.ctf_ami[0].id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = { Name = "${var.name_prefix}-from-ami" }
}
