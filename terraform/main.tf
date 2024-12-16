terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = var.bucket_name
    key    = "aws/ec2-deploy/terraform.tfstate"
    region = var.region
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "server" {
  ami                    = "ami-075449515af5df0d1"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.mainGroup.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2-profile.name

  tags = {
    name = "deployVM"
  }
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-profile"
  role = "ec2-ecr-auth"
}

resource "aws_security_group" "mainGroup" {
  egress = [
    {
      cidr_blocks       = ["0.0.0.0/0"]
      description       = ""
      from_port         = 0
      ipv6_cidr_blocks  = []
      prefix_list_ids   = []
      protocol          = "-1"
      security_groups   = []
      self              = false
      to_port           = 0
    }
  ]

  ingress = [
    {
      cidr_blocks       = ["0.0.0.0/0"]
      description       = ""
      from_port         = 22
      ipv6_cidr_blocks  = []
      prefix_list_ids   = []
      protocol          = "tcp"
      security_groups   = []
      self              = false
      to_port           = 22
    },
    {
      cidr_blocks       = ["0.0.0.0/0"]
      description       = ""
      from_port         = 80
      ipv6_cidr_blocks  = []
      prefix_list_ids   = []
      protocol          = "tcp"
      security_groups   = []
      self              = false
      to_port           = 80
    },
    {
      cidr_blocks       = ["0.0.0.0/0"]
      description       = ""
      from_port         = 443
      ipv6_cidr_blocks  = []
      prefix_list_ids   = []
      protocol          = "tcp"
      security_groups   = []
      self              = false
      to_port           = 443
    }
  ]
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.public_key
}

output "instance_public_ip" {
  value = aws_instance.server.public_ip
}