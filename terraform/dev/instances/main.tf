#----------------------------------------------------------
# ACS730 - Week 3 - Terraform Introduction
#
# Build EC2 Instances and Create ECR Repository
#
#----------------------------------------------------------

# Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Data block to retrieve the default VPC id
data "aws_vpc" "default" {
  default = true
}

# Define tags locally
locals {
  default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
  prefix       = module.globalvars.prefix
  name_prefix  = "${local.prefix}"
}

# Retrieve global variables from the Terraform module
module "globalvars" {
  source = "../../modules/globalvars"
}

# Reference subnet provisioned by 01-Networking
resource "aws_instance" "my_instance" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.my_key.key_name
  vpc_security_group_ids      = [aws_security_group.my_sg.id]
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-my-instance-Linux"
    }
  )
}

# Create two more instances
# resource "aws_instance" "my_instance_1" {
#   ami                         = data.aws_ami.latest_amazon_linux.id
#   instance_type               = lookup(var.instance_type, var.env)
#   key_name                    = aws_key_pair.my_key.key_name
#   vpc_security_group_ids      = [aws_security_group.my_sg.id]
#   associate_public_ip_address = false

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = merge(local.default_tags,
#     {
#       "Name" = "${local.name_prefix}-my-instance-1"
#     }
#   )
# }

# resource "aws_instance" "my_instance_2" {
#   ami                         = data.aws_ami.latest_amazon_linux.id
#   instance_type               = lookup(var.instance_type, var.env)
#   key_name                    = aws_key_pair.my_key.key_name
#   vpc_security_group_ids      = [aws_security_group.my_sg.id]
#   associate_public_ip_address = false

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = merge(local.default_tags,
#     {
#       "Name" = "${local.name_prefix}-my-instance-2"
#     }
#   )
# }

# Adding SSH key to Amazon EC2
resource "aws_key_pair" "my_key" {
  key_name   = local.name_prefix
  public_key = file("~/.ssh/${local.name_prefix}.pub")
}

# Security Group
resource "aws_security_group" "my_sg" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "node port service"
    from_port        = 30000
    to_port          = 30000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-sg"
    }
  )
}

# Elastic IP
resource "aws_eip" "static_eip_my_instance" {
  instance = aws_instance.my_instance.id
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-eip"
    }
  )
}
# resource "aws_eip" "static_eip_my_instance_1" {
#   instance = aws_instance.my_instance_1.id
#   tags = merge(local.default_tags,
#     {
#       "Name" = "${local.name_prefix}-eip"
#     }
#   )
# }
# resource "aws_eip" "static_eip_my_instance_2" {
#   instance = aws_instance.my_instance_2.id
#   tags = merge(local.default_tags,
#     {
#       "Name" = "${local.name_prefix}-eip"
#     }
#   )
# }
# Elastic Container Registry (ECR) - Create a new repository
resource "aws_ecr_repository" "my_ecr_repo" {
  name                 = lower("${local.name_prefix}-ecr-repo")
  image_tag_mutability = "MUTABLE"
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-ecr-repo"
    }
  )
}
