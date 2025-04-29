resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}
