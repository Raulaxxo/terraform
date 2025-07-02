provider "aws" {
  region = "us-east-1" 
  profile = "Raxxo"
}

resource "aws_vpc" "raxxo_vpc" {
  cidr_block = "10.10.10.0/28"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "RaxxoVPC"
  }
}

resource "aws_internet_gateway" "raxxo_igw" {
  vpc_id = aws_vpc.raxxo_vpc.id

  tags = {
    Name = "RaxxoIGW"
  }
}

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

# (Opcional) Asociar la tabla de rutas a una subred (ejemplo):
resource "aws_subnet" "raxxo_subnet" {
  vpc_id            = aws_vpc.raxxo_vpc.id
  cidr_block        = "10.10.10.0/28"
  availability_zone = "us-east-1a"  # Cambia la AZ si quieres

  tags = {
    Name = "RaxxoSubnet"
  }
}

resource "aws_route_table_association" "a_subnet" {
  subnet_id      = aws_subnet.raxxo_subnet.id
  route_table_id = aws_route_table.raxxo_route_table.id
}


