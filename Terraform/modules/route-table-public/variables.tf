variable "vpc_id" {
  type = string
}

variable "internet_gateway_id" {
  type = string
}

variable "name" {
  type = string
}

variable "public_subnet_id" {
  description = "ID of the private subnet to associate with this route table"
  type        = string
}