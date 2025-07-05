provider "aws" {
  region  = "us-east-1"
  profile = "Raxxo"
}

# Variables locales
locals {
  vpc_cidr      = "10.10.10.0/27"
  subnet1_cidr  = "10.10.10.0/28"
  subnet2_cidr  = "10.10.10.16/28"
}

# VPC
resource "aws_vpc" "raxxo_vpc" {
  cidr_block           = local.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "RaxxoVPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "raxxo_igw" {
  vpc_id = aws_vpc.raxxo_vpc.id

  tags = {
    Name = "RaxxoIGW"
  }
}

# Tabla de rutas
resource "aws_route_table" "raxxo_route_table" {
  vpc_id = aws_vpc.raxxo_vpc.id

  tags = {
    Name = "RaxxoRouteTable"
  }
}

resource "aws_route" "route_internet" {
  route_table_id         = aws_route_table.raxxo_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.raxxo_igw.id
}

# Subnet 1 - 10.10.10.0/28
resource "aws_subnet" "raxxo_subnet_1" {
  vpc_id            = aws_vpc.raxxo_vpc.id
  cidr_block        = local.subnet1_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "RaxxoSubnet1"
  }
}

# Subnet 2 - 10.10.10.16/28
resource "aws_subnet" "raxxo_subnet_2" {
  vpc_id            = aws_vpc.raxxo_vpc.id
  cidr_block        = local.subnet2_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = "RaxxoSubnet2"
  }
}

# Asociaciones a la tabla de rutas
resource "aws_route_table_association" "a_subnet_1" {
  subnet_id      = aws_subnet.raxxo_subnet_1.id
  route_table_id = aws_route_table.raxxo_route_table.id
}

resource "aws_route_table_association" "a_subnet_2" {
  subnet_id      = aws_subnet.raxxo_subnet_2.id
  route_table_id = aws_route_table.raxxo_route_table.id
}

# Outputs
output "vpc_id" {
  value = aws_vpc.raxxo_vpc.id
}

output "subnet1_id" {
  value = aws_subnet.raxxo_subnet_1.id
}

output "subnet2_id" {
  value = aws_subnet.raxxo_subnet_2.id
}

output "subnet1_cidr" {
  value = aws_subnet.raxxo_subnet_1.cidr_block
}

output "subnet2_cidr" {
  value = aws_subnet.raxxo_subnet_2.cidr_block
}
