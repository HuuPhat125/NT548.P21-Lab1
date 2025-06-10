resource "aws_security_group" "public_sg" {
  name   = "public-sg"
  vpc_id = var.vpc_id
  description = "Security group for public subnet"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_ip]
    description = "allowed ssh ip access"

  }

  egress {
    from_port   = 0
    to_port     = 0
    # protocol    = "-1"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS only"
  }
}
