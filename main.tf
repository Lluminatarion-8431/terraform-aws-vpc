# main.tf - Phase 2: Refactored to cidrsubnet() (zero-diff from Phase 1.1)

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

locals {
  vpc_cidr = "10.0.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr

  tags = {
    Name = "rep2-vpc"
  }
}

# Public Subnets (netnum 0 and 1)
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 8, 0)
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "rep2-public-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 8, 1)
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "rep2-public-2"
  }
}

# Private Subnets (netnum 10 and 11)
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(local.vpc_cidr, 8, 10)
  availability_zone = "us-west-2a"

  tags = {
    Name = "rep2-private-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(local.vpc_cidr, 8, 11)
  availability_zone = "us-west-2b"

  tags = {
    Name = "rep2-private-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "rep2-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "rep2-public-rt"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "rep2-private-rt"
  }
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

# Outputs
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the VPC"
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
  description = "IDs of the public subnets"
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
  description = "IDs of the private subnets"
}

output "public_subnet_cidrs" {
  value = [
    aws_subnet.public_1.cidr_block,
    aws_subnet.public_2.cidr_block
  ]
  description = "CIDR blocks of the public subnets"
}

output "private_subnet_cidrs" {
  value = [
    aws_subnet.private_1.cidr_block,
    aws_subnet.private_2.cidr_block
  ]
  description = "CIDR blocks of the private subnets"
}
