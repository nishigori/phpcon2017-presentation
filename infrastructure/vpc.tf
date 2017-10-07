module "vpc" {
  source = "git@github.com:hashicorp/best-practices?ref=abdc7d4//terraform/modules/aws/network/vpc"

  cidr = "10.0.0.0/16"
}

module "public_subnet" {
  source = "git@github.com:hashicorp/best-practices?ref=abdc7d4//terraform/modules/aws/network/public_subnet"

  vpc_id = "${module.vpc.vpc_id}"
  cidrs  = "${cidrsubnet(module.vpc.vpc_cidr, 8, 1)},${cidrsubnet(module.vpc.vpc_cidr, 8, 3)}"
  azs    = "${join(",", var.availability_zones)}"
}

module "nat" {
  source = "git@github.com:hashicorp/best-practices?ref=abdc7d4//terraform/modules/aws/network/nat"

  azs               = "${join(",", var.availability_zones)}"
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
}

module "private_subnet" {
  source = "git@github.com:hashicorp/best-practices?ref=abdc7d4//terraform/modules/aws/network/private_subnet"

  vpc_id          = "${module.vpc.vpc_id}"
  cidrs           = "${cidrsubnet(module.vpc.vpc_cidr, 8, 11)},${cidrsubnet(module.vpc.vpc_cidr, 8, 13)}"
  azs             = "${join(",", var.availability_zones)}"
  nat_gateway_ids = "${module.nat.nat_gateway_ids}"
}
