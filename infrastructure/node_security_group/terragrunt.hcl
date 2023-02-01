include "root" {
  path = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}


terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group//."
}


include "vpc" {
  path           = "..//dependency-blocks/vpc.hcl"
  expose         = true
  merge_strategy = "deep"
}




inputs = {

  name = "node_group_one"

  description = "node_group_one"

  vpc_id      = dependency.vpc.outputs.vpc_id


  ingress_with_cidr_blocks = [

    {

      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "10.0.0.0/16"

    }
  ]

  egress_with_cidr_blocks = [

    {

      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "SSH"
      cidr_blocks = "10.0.0.0/16"
      
    }
  ]
}


