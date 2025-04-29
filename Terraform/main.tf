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
