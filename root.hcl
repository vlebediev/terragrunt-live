locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  aws_account     = local.account_vars.locals.aws_account
  environment     = local.env_vars.locals.environment
  aws_region      = local.region_vars.locals.aws_region
  domain          = local.global_vars.locals.domain
  tf_module_version = local.global_vars.locals.tf_module_version
  modules_repo    = "git::git@github.com:vlebediev/terraform-task.git"
#  modules_repo = "../../../../../../terraform-task//"

}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "tfstate-${local.aws_account}-${local.aws_region}" 
    key            = "${path_relative_to_include()}/terraform.tfstate"   
    region         = local.aws_region
    encrypt        = true
    use_lockfile = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<PROVIDER
provider "aws" {
  region              = "${local.aws_region}"
  allowed_account_ids = ["${local.aws_account}"]
  default_tags {
    tags = {
      Environment = "${local.environment}"
      ManagedBy   = "terragrunt"
    }
  }
}
PROVIDER
}

inputs = {
  environment = local.environment
  aws_region  = local.aws_region
}
