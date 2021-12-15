provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "web" {
  ami           = "ami-05d34d340fb1d89e5"
  instance_type = "t2.micro"
}

resource "aws_vpc" "main" {
  cidr_block = "10.8.0.0/16"
}

resource "aws_subnet" "new-private-01" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.8.0.0/18"

  tags = {
    Name = "new-private-01"
  }
}

resource "aws_subnet" "new-private-02" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.8.64.0/18"

  tags = {
    Name = "new-private-02"
  }
}

resource "aws_subnet" "new-public-01" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.8.128.0/18"
  map_public_ip_on_launch = true

  tags = {
    Name = "new-public-01"
  }
}
