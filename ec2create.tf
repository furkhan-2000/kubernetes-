terraform { 
  required_providers {
    aws = {
      source = "hashi/corp"
      version = "5.85.0"
    }
  }
}

  provider "aws" {
    region = "eu-central-1"
  }

 aws_resource "aws_vpc" "euvpc" {
  cidr_block = "172.31.32.0/16"

  tags = {
    Name = euvpc
  }
 }

 aws_resource "aws_subnet" "eusubnet" {
  vpc_id = aws_vpc.euvpc.id 
  cidr_block = 172.31.32.0/20
  availability_zone = "eu-central-1"
  map_public_ip_on_launch = true 

  tags {
    Name = "eusubnet"
  }
 }

 aws_resource "aws_internet_gateway" "euinternet" {
  vpc_id = aws_vpc.euvpc.id 

  tags {
    Name = "euinternet"
  }
 }
 