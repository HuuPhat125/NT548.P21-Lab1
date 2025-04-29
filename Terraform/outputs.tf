output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_ec2_id" {
  value = module.ec2_public.instance_id
}

output "public_ec2_ip" {
  value = module.ec2_public.public_ip
}

output "private_ec2_id" {
  value = module.ec2_private.instance_id
}

output "private_ec2_ip" {
  value = module.ec2_private.private_ip
}

output "nat_gateway_id" {
  value = module.nat_gateway.nat_gateway_id
}
