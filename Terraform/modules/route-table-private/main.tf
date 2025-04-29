resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.name}-private"
  }
}

resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateway_id
}
