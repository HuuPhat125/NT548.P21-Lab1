variable "vpc_id" {
  type = string
}

variable "nat_gateway_id" {
  type = string
}

variable "name" {
  type = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet to associate with this route table"
  type        = string
}

