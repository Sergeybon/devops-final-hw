
variable "instance_name" {
  type        = string
  description = "Instance name"
}

variable "instance_name2" {
  type        = string
  description = "Instance name2"
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


resource "aws_iam_instance_profile" "ec2-registry" {
  name = "registry-read"
  role = aws_iam_role.ec2-role.name
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