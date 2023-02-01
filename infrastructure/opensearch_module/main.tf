resource "aws_opensearch_domain" "example" {
  domain_name     = var.domain_name
  engine_version  = var.engine_version
  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:${var.region}:999360891534:domain/${var.domain_name}/*"
    }
  ]
}
CONFIG

  cluster_config {
    instance_type  = var.instance_type
    instance_count = var.instance_count

  }

  advanced_security_options {
    enabled                        = var.advanced_security_options_enabled
    anonymous_auth_enabled         = var.advanced_security_options_anonymous_auth_enabled
    internal_user_database_enabled = var.advanced_security_options_internal_user_database_enabled
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }

  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption_enabled
  }

  encrypt_at_rest {
    enabled = var.encrypt_at_rest_enabled
  }

  domain_endpoint_options {
    enforce_https       = var.domain_endpoint_options_enforce_https
    tls_security_policy = var.domain_endpoint_options_tls_security_policy
  }

  ebs_options {
    ebs_enabled = var.ebs_options_ebs_enabled
    volume_size = var.ebs_options_volume_size
  }

}
