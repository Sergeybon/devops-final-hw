variable "instance_name" {
  type        = string
  description = "Please enter Instance name"
}

variable "instance_name2" {
  type        = string
  description = "Please enter Instance name2"
}

variable "aws_region" {

  description = "Please enter region"
}
#
#variable "bucket_name" {
#  type        = string
#  description = "Name of S3 Bucket for tfstate file"
#}
#variable "dynamo_billing_mode" {
#  type        = string
#  description = "billing_mode = PAY_PER_REQUEST for DynamoDB"
#}
#variable "dynamo_name" {
#  type        = string
#  description = "Name of DynamoDB lock table"
#}
#
#variable "dom_name" {
#  type        = string
#  description = "domain names in the certificate"
#
#}

#variable "domain_names" {
#  description = "List of domain names in the certificate"
#  type = list(object({
#    record_name = string
#    zone_name = string
#  }))
#}
#
#variable "subject_alternative_name_prefixes" {
#  description = "Alternative names for the domain. Wildcards may be used. (*.example.com, etc)"
#  type        = list(string)
#  default     = null
#}
#
#variable "hosted_zone" {
#  description = "Route53 Hosted Zone"
#  type        = string
#
#}