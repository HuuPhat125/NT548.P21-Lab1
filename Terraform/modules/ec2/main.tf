resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  vpc_security_group_ids = [var.sg_id]
  associate_public_ip_address = var.associate_public_ip
  tags = {
    Name = var.name
  }
}
