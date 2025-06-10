resource "aws_security_group" "private_sg" {
  name   = "private-sg"
  vpc_id = var.vpc_id
  description = "Security group for private subnet"
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.public_sg_id]
    description = "Allow SSH from bastion"

  }

  egress {
    from_port   = 0
    to_port     = 0
    # protocol    = "-1"
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS only"
  }
}
