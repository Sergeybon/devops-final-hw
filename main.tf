#----------------------------------------------------------
#
# AWS 2 NGINX+ALB
#
# Made by Sergey Bondarenko
#
#----------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
  shared_credentials_file = "/Users/siarhei/.aws/credentials"
}

resource "aws_ecr_repository" "python" {
  name                 = "testpython"
}
