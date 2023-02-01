skip = true


locals {

  environment_vars = read_terragrunt_config(find_in_parent_folders("common_vars.hcl"))

  aws_region = local.environment_vars.locals.aws_region

}




remote_state {

  backend = "s3"

  generate = {

    path      = "_backend.tf"
    if_exists = "overwrite_terragrunt"

  }


  config = {

    bucket  = "project-terraform-tfstate"
    region  = "eu-central-1"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    encrypt = true

  }
}




generate "provider" {

  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  profile = "default"
}
EOF
}
