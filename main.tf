provider "aws" {
  region = "eu-central-1"
  shared_credentials_file = "/Users/siarhei/.aws/credentials"
}

variable "instance_name" {
  type        = string
  description = "Instance name"
}

variable "instance_name2" {
  type        = string
  description = "Instance name2"
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

resource "aws_subnet" "new-public-02" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.8.192.0/18"
  map_public_ip_on_launch = true

  tags = {
    Name = "new-public-02"
  }
}

resource "aws_lb" "mylb" {
  name               = "testterraformlb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_web.id]
  subnets            = [aws_subnet.new-public-01.id, aws_subnet.new-public-02.id]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "WebHTTP" {
  load_balancer_arn = aws_lb.mylb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myec2.arn
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.sbondar05.ga"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.test_instance.*.public_ip]
}

resource "aws_lb_listener" "WebHTTPS" {
  load_balancer_arn = aws_lb.mylb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myec2.arn
  }
}

resource "aws_lb_target_group" "myec2" {
  name        = "testpython"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "testpython" {
  target_group_arn = aws_lb_target_group.myec2.arn
  target_id        = aws_instance.test_instance.id
  port             = 8080
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow WEB inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress = [
    {
      description      = "WEB from World"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]
egress = [
    {
      description      = "for all outgoing traffics"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]


  tags = {
    Name = "allow_web"
  }
}

resource "aws_security_group" "allow_elb" {
  name        = "allow_elb"
  description = "Allow ELB inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress = [
    {
      description      = "From ELB to EC2"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = [aws_security_group.allow_web.id]
      self = false
    }
  ]
egress = [
    {
      description      = "for all outgoing traffics"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]


  tags = {
    Name = "allow_elb"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "myigw"
  }
}

resource "aws_route_table" "default_rt" {
  vpc_id = aws_vpc.main.id

  route = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.myigw.id
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      nat_gateway_id             = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }
  ]

  tags = {
    Name = "myroutetable"
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.default_rt.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress = [
    {
      description      = "SSH from World"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]
egress = [
    {
      description      = "for all outgoing traffics"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]


  tags = {
    Name = "allow_ssh"
  }
}



resource "aws_iam_role" "ec2-role" {
  name = "ec2-read-registry"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "read-registry" {
  name = "read-registry"
  role = aws_iam_role.ec2-role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
        "Action": [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetRepositoryPolicy",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
            "ecr:DescribeImages",
            "ecr:BatchGetImage",
            "ecr:GetLifecyclePolicy",
            "ecr:GetLifecyclePolicyPreview",
            "ecr:ListTagsForResource",
            "ecr:DescribeImageScanFindings"
        ],
        "Resource": "*"
        },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2-registry" {
  name = "registry-read"
  role = aws_iam_role.ec2-role.name
}

resource "aws_instance" "test_instance" {
  ami           = "ami-05d34d340fb1d89e5"
    instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_elb.id]
  subnet_id = aws_subnet.new-public-01.id
  iam_instance_profile = aws_iam_instance_profile.ec2-registry.name
  root_block_device {
    volume_size = 8
  }

  tags = {
    Name = var.instance_name
  }
}

resource "aws_instance" "test_instance2" {
  ami           = "ami-05d34d340fb1d89e5"
    instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_elb.id]
  subnet_id = aws_subnet.new-public-02.id
  iam_instance_profile = aws_iam_instance_profile.ec2-registry.name
  root_block_device {
    volume_size = 8
  }

  tags = {
    Name = var.instance_name2
  }
}

resource "aws_ecr_repository" "python" {
  name                 = "testpython"
}

output "instance_ip" {
  value = aws_instance.test_instance.*.public_ip
}