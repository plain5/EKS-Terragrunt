include "root" {
  path = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}


terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-ecr//."
}




inputs = {

  repository_name = "node-app"

  repository_image_tag_mutability = "IMMUTABLE"

  repository_image_scan_on_push = false

  repository_type = "private"

  create_repository_policy = false

  create_lifecycle_policy = false

  attach_repository_policy = false
  
}