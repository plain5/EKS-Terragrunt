variable "domain_name" {
  type    = string
  default = ""
}

variable "engine_version" {
  type    = string
  default = ""
}

variable "instance_type" {
  type    = string
  default = ""
}

variable "instance_count" {
  type    = number
  default = null
}

variable "advanced_security_options_enabled" {
  type    = bool
  default = true
}

variable "advanced_security_options_anonymous_auth_enabled" {
  type    = bool
  default = false
}

variable "advanced_security_options_internal_user_database_enabled" {
  type    = bool
  default = true
}

variable "master_user_name" {
  type    = string
  default = ""
}

variable "master_user_password" {
  type    = string
  default = ""
}

variable "node_to_node_encryption_enabled" {
  type    = bool
  default = true
}

variable "encrypt_at_rest_enabled" {
  type    = bool
  default = true
}

variable "domain_endpoint_options_enforce_https" {
  type    = bool
  default = true
}

variable "domain_endpoint_options_tls_security_policy" {
  type    = string
  default = "Policy-Min-TLS-1-2-2019-07"
}

variable "ebs_options_ebs_enabled" {
  type    = bool
  default = true
}

variable "ebs_options_volume_size" {
  type    = number
  default = null
}

variable "region" {
  type    = string
  default = ""
}
