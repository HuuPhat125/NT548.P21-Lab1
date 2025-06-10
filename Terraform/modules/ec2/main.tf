resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  vpc_security_group_ids = [var.sg_id]
  # associate_public_ip_address = var.associate_public_ip
  associate_public_ip_address = var.associate_public_ip # checkov:skip=CKV_AWS_88: Public IP is required for public-facing EC2
  

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"  
  }
  root_block_device {
    encrypted = true
  }
  monitoring = true
  ebs_optimized = true

  tags = {
    Name = var.name
  }
}
