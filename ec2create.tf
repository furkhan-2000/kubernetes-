terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.85.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "rylvpc" {
  cidr_block = "172.31.0.0/16"

  tags = {
    Name = "rylvpc"
  }
}

resource "aws_subnet" "rylsubnet" {
  vpc_id                  = aws_vpc.rylvpc.id
  cidr_block              = "172.31.32.0/20"
  availability_zone       = "eu-west-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "rylsubnet"
  }
}

resource "aws_internet_gateway" "rylgateway" {
  vpc_id = aws_vpc.rylvpc.id

  tags = {
    Name = "rylgateway"
  }
}

resource "aws_route_table" "rylroute" {
  vpc_id = aws_vpc.rylvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rylgateway.id
  }
}

resource "aws_route_table_association" "rylroute_assoc" {
  subnet_id      = aws_subnet.rylsubnet.id
  route_table_id = aws_route_table.rylroute.id
}

resource "aws_instance" "ec2" {
  ami           = ""  
  instance_type = "t2.micro"
  key_name      = "ireland"

  user_data = <<-EOF
    #!/bin/bash 
    sudo yum update -y 
    sudo yum install docker -y 
    sudo systemctl start docker && sudo systemctl enable docker 
    sudo docker pull furkhan2000/shark:httpdneo
  EOF

  tags = {
    Name = "ec2"
  }
}

variable "sg_ports" {
  type        = list(number)
  description = "This is for ingress and egress"
  default     = [8200, 8300, 9200, 9500]
}

resource "aws_security_group" "dynamicsg" {
  name        = "dynamicsg"
  description = "demo"
  vpc_id      = aws_vpc.rylvpc.id

  dynamic "ingress" {
    for_each = var.sg_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = var.sg_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_eip" "ryleip" {
  instance = aws_instance.ec2.id
  domain   = "vpc"
}

output "public_ip" {
  value = aws_instance.ec2.public_ip
}

output "instance_id" {
  value = aws_instance.ec2.id
}

output "private_ip" {
  value = aws_instance.ec2.private_ip
}

output "public_dns" {
  value = aws_instance.ec2.public_dns
}
