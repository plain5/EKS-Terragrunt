include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}


terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-eks//.?ref=v19.5.1"
}


include "vpc" {
  path           = "..//dependency-blocks/vpc.hcl"
  expose         = true
  merge_strategy = "deep"
}


include "node_security_group" {
  path           = "..//dependency-blocks/node_security_group.hcl"
  expose         = true
  merge_strategy = "deep"
}


include "efs" {
  path           = "..//dependency-blocks/efs_security_group.hcl"
  expose         = true
  merge_strategy = "deep"
}




locals {

  environment_vars = read_terragrunt_config(find_in_parent_folders("common_vars.hcl"))

  cluster_name = local.environment_vars.locals.cluster_name
  aws_region = local.environment_vars.locals.aws_region

}




generate "provider-local" {
  path      = "provider-local.tf"
  if_exists = "overwrite"
  contents  = file("..//eks_provider_config/eks.tf")
}




inputs = {

  aws = {

    "region" = "${local.aws_region}"
    "profile" = "default"

  }


  cluster_name = local.cluster_name

  cluster_version = "1.24"


  vpc_id = dependency.vpc.outputs.vpc_id

  subnet_ids = dependency.vpc.outputs.private_subnets

  cluster_endpoint_public_access = true

  cluster_enabled_log_types = ["audit", "api", "authenticator", "controllerManager", "scheduler"]

  create_cloudwatch_log_group = true

  cloudwatch_log_group_retention_in_days = 7

  eks_managed_node_group_defaults = {

    ami_type = "AL2_x86_64"

  }


  eks_managed_node_groups = {

    one = {

      name = "node-group-1"

      instance_types = ["c6a.xlarge"]

      min_size     = 1

      max_size     = 2

      desired_size = 1

      vpc_security_group_ids = [

        "${dependency.node_security_group.outputs.security_group_id}",

        "${dependency.efs.outputs.security_group_id}"

      ]

      iam_role_additional_policies = {

        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
        
      }
    }
  }
}