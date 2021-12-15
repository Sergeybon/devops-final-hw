provider "aws" {
  region = "eu-central-1"
  shared_credentials_file = "/Users/siarhei/.aws/credentials"
}



resource "aws_ecr_repository" "python" {
  name                 = "testpython"
}

output "instance_ip" {
  value = aws_instance.test_instance.*.public_ip
}