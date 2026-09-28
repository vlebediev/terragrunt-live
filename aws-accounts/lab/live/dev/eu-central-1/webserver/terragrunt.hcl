include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${include.root.locals.modules_repo}//modules/wordpress?ref=${include.root.locals.modules_version}"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id            = "vpc-mock"
    public_subnet_ids = ["subnet-mock"]
  }
}

dependency "rds" {
  config_path = "../rds"
  mock_outputs = {
    endpoint = "mock.rds.amazonaws.com"
  }
}

inputs = {
  name        = "vlebediev-tg-wordpress"
  ami_id      = "ami-03b2339b9507d3747"
  vpc_id      = dependency.vpc.outputs.vpc_id
  subnet_id   = dependency.vpc.outputs.public_subnet_ids[0]
  aws_region  = "eu-central-1"
  domain_name = include.root.locals.domain
  zone_name   = include.root.locals.domain
  enable_eip  = true
}
