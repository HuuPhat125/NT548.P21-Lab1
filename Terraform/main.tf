provider "aws" {
  region = var.region
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.vpc_cidr
  name       = "my-vpc"
}

module "internet_gateway" {
  source = "./modules/internet-gateway"
  vpc_id = module.vpc.vpc_id
  name   = "my-igw"
}

module "public_subnet" {
  source          = "./modules/subnet"
  vpc_id          = module.vpc.vpc_id
  cidr_block      = var.public_subnet_cidr
  az              = var.az_1
  map_public_ip   = true
  name            = "public-subnet"
}

module "private_subnet" {
  source          = "./modules/subnet"
  vpc_id          = module.vpc.vpc_id
  cidr_block      = var.private_subnet_cidr
  az              = var.az_1
  map_public_ip   = false
  name            = "private-subnet"
}

module "nat_gateway" {
  source            = "./modules/nat-gateway"
  public_subnet_id  = module.public_subnet.subnet_id
}


module "route_table_public" {
  source              = "./modules/route-table-public"
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.igw_id
  name                = "public-rt"
}

module "route_table_private" {
  source          = "./modules/route-table-private"
  vpc_id          = module.vpc.vpc_id
  nat_gateway_id  = module.nat_gateway.nat_gateway_id
  name            = "private-rt"
}



module "sg_public" {
  source         = "./modules/security-group-public"
  vpc_id         = module.vpc.vpc_id
  allowed_ssh_ip = var.allowed_ssh_ip
}

module "sg_private" {
  source         = "./modules/security-group-private"
  vpc_id         = module.vpc.vpc_id
  public_sg_id   = module.sg_public.sg_id
}


module "ec2_public" {
  source               = "./modules/ec2"
  ami                  = var.ami
  instance_type        = var.instance_type
  subnet_id            = module.public_subnet.subnet_id
  key_name             = var.key_name
  sg_id                = module.sg_public.sg_id
  associate_public_ip  = true
  name                 = "public-ec2"
}

module "ec2_private" {
  source               = "./modules/ec2"
  ami                  = var.ami
  instance_type        = var.instance_type
  subnet_id            = module.private_subnet.subnet_id
  key_name             = var.key_name
  sg_id                = module.sg_private.sg_id
  associate_public_ip  = false
  name                 = "private-ec2"
}
