#----------------------------------------------------------
#
# AWS 2 NGINX+ALB
#
# Made by Sergey Bondarenko
#
#----------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "test-s3-for-terraform-deployment-states"
    key    = "testterraform"
    dynamodb_table = "test-s3-for-terraform-deployment-locks"
    region = "eu-central-1"
  }
}


provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = "/Users/siarhei/.aws/credentials"
}

#resource "aws_ecr_repository" "testterraform" {
#  name = "testterraform"
#}
