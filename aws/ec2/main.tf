provider "aws" {
  profile = "Raxxo"
  region  = "us-east-1"
}

# Buscar última AMI de Amazon Linux 2
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Obtener subnets de la VPC
data "aws_subnets" "raxxo_subnets" {
  filter {
    name   = "vpc-id"
    values = ["vpc-0f162a65890522d02"]
  }
}

# Par de llaves SSH
resource "aws_key_pair" "raxxo_key" {
  key_name   = "raxxo-key"
  public_key = file("~/.ssh/Raxxo/raxxokey.pub") # <-- cambia si es necesario
}

# Security Group para SSH
resource "aws_security_group" "raxxo_sg" {
  name        = "RaxxoAllowSSH"
  description = "Allow SSH from anywhere"
  vpc_id      = "vpc-0f162a65890522d02"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group para HTTP y HTTPS
resource "aws_security_group" "raxxo_web_sg" {
  name        = "RaxxoWebSG"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = "vpc-0f162a65890522d02"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instancia EC2
resource "aws_instance" "raxxo_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.raxxo_subnets.ids[0]
  vpc_security_group_ids      = [
    aws_security_group.raxxo_sg.id,
    aws_security_group.raxxo_web_sg.id
  ]
  key_name                    = aws_key_pair.raxxo_key.key_name
  associate_public_ip_address = true
  user_data_base64            = filebase64("installapps.sh")

  tags = {
    Name = "Raxxo-Ec2"
  }
}

# Output: IP pública
output "instance_public_ip" {
  value = aws_instance.raxxo_ec2.public_ip
}
