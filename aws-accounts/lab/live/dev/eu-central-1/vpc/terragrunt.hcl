include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}
terraform {
  source = "${include.root.locals.modules_repo}//modules/vpc?ref=${include.root.locals.tf_module_version}"
  }
inputs = {
  vpc_name        = "vlebediev-tg-vpc"
  vpc_cidr        = "10.20.0.0/16"
  public_subnets  = ["10.20.1.0/24"]
  private_subnets = ["10.20.2.0/24", "10.20.3.0/24"]
  nat_enabled     = false
}
