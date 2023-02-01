// include "root" {
//   path = find_in_parent_folders()
//   expose         = true
//   merge_strategy = "deep"
// }


// terraform {
//   source = "github.com/terraform-aws-modules/terraform-aws-route53/modules/records//."
// }


// include "datasources" {
//   path           = "..//dependency-blocks/datasources.hcl"
//   expose         = true
//   merge_strategy = "deep"
// }




// locals {

//   environment_vars = read_terragrunt_config(find_in_parent_folders("common_vars.hcl"))

//   zone_name = local.environment_vars.locals.zone_name

//   elb_dns_name = local.environment_vars.locals.elb_dns_name

// }




// inputs = {

//     zone_name = "${local.zone_name}"

//     records_jsonencoded = jsonencode([

//     {

//         name = "its"
//         type = "A"
//         alias   = {
//           name    = "${local.elb_dns_name}"
//           zone_id = "${dependency.datasources.outputs.elb_zone_id}"
          
//         }
//     }    
//     ]) 
// }




// dependencies {

//   paths = [

//     "..//datasources",
//     "..//ecr",
//     "..//vpc",
//     "..//node_security_group",
//     "..//efs",
//     "..//eks_cluster",
//     "..//opensearch"
//   ]
// }