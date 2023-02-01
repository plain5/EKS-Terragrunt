include "root" {
  path = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}


terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc//.?ref=v3.19.0"
}


include "datasources" {
  path           = "..//dependency-blocks/datasources.hcl"
  expose         = true
  merge_strategy = "deep"
}




locals {

  environment_vars = read_terragrunt_config(find_in_parent_folders("common_vars.hcl"))

  cluster_name = local.environment_vars.locals.cluster_name

}




inputs = {

  name = "education-vpc"

  cidr = "10.0.0.0/16"

  azs  = slice(dependency.datasources.outputs.aws_availability_zones_names, 0, 3)


  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]


  enable_nat_gateway   = true

  single_nat_gateway   = true

  enable_dns_hostnames = true


  public_subnet_tags = {

    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1

  }


  private_subnet_tags = {

    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
    
  }
}