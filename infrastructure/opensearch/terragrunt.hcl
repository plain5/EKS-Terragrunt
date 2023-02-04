include "root" {
  path = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}


terraform {
  source = "..//opensearch_module//."
}





inputs = {

    domain_name    = "its-application"
    engine_version = "OpenSearch_2.3"

    region = "us-east-1"

    instance_type  = "t3.small.search"
    instance_count = 1

    advanced_security_options_enabled                        = true
    advanced_security_options_anonymous_auth_enabled         = false
    advanced_security_options_internal_user_database_enabled = true

    master_user_name     = "YOUR_MASTER_USER_NAME"
    master_user_password = "YOUR_MASTER_USER_PASSWORD"

    node_to_node_encryption_enabled = true

    encrypt_at_rest_enabled = true

    domain_endpoint_options_enforce_https       = true
    domain_endpoint_options_tls_security_policy = "Policy-Min-TLS-1-2-2019-07"

    ebs_options_ebs_enabled = true
    ebs_options_volume_size = 10
}




dependencies {

  paths = [

    "..//datasources",
    "..//ecr",
    "..//vpc",
    "..//node_security_group",
    "..//efs",
    "..//eks_cluster"

  ]
}