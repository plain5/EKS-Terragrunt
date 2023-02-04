include "root" {
  path = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}



terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-efs//."
}



include "datasources" {
  path           = "..//dependency-blocks/datasources.hcl"
  expose         = true
  merge_strategy = "deep"
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



inputs = {

  name = "EFS for K8s cluster"

  creation_token = "k8s_cluster_efs"

  performance_mode = "generalPurpose"

  throughput_mode  = "bursting"

  encrypted = true

  attach_policy = false

  create_backup_policy = false

  enable_backup_policy = false




  mount_targets = {

    "${dependency.datasources.outputs.aws_availability_zones_names[0]}" = {
      subnet_id = dependency.vpc.outputs.private_subnets[0]
    }

    "${dependency.datasources.outputs.aws_availability_zones_names[1]}" = {
      subnet_id = dependency.vpc.outputs.private_subnets[1]
    }

    "${dependency.datasources.outputs.aws_availability_zones_names[2]}" = {
      subnet_id = dependency.vpc.outputs.private_subnets[2]

    }
  }




  security_group_name = "SG-for-EFS"

  security_group_description = "SG-for-EFS"

  security_group_vpc_id = dependency.vpc.outputs.vpc_id

  security_group_use_name_prefix = true

  
  security_group_rules = {

    ing = {

      description = "NFS Ingress"
      source_security_group_id = dependency.node_security_group.outputs.security_group_id

      from_port = 2049
      to_port = 2049
      protocol = "tcp"
      type = "ingress"

    },

    egr = {

      description = "NFS Egress"
      type = "egress"

      source_security_group_id = dependency.node_security_group.outputs.security_group_id
      from_port = 0
      to_port = 0
      protocol = "-1"
      
    }
  }
}




 
