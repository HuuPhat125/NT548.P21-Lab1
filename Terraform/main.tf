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