data "aws_availability_zones" "available" {}


data "aws_elb_hosted_zone_id" "main" {}




output "aws_availability_zones_names" {
  value = data.aws_availability_zones.available.names
}


output "elb_zone_id" {
  value = data.aws_elb_hosted_zone_id.main.id
}
