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

# Obtener subnets de la VPC (usaremos la primera)
data "aws_subnets" "raxxo_subnets" {
  filter {
    name   = "vpc-id"
    values = ["vpc-0005283161467b1c6"]
  }
}

# Par de llaves
resource "aws_key_pair" "raxxo_key" {
 key_name   = "raxxo-key"
 public_key = file("~/.ssh/Raxxo/raxxokey.pub")
}

# Security Group para SSH
resource "aws_security_group" "raxxo_sg" {
  name        = "RaxxoAllowSSH"
  description = "Allow SSH from anywhere"
  vpc_id      = "vpc-0005283161467b1c6"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # O puedes restringir por IP pública
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
  subnet_id                   = data.aws_subnets.raxxo_subnets.ids[0] # Primera subnet
  vpc_security_group_ids      = [aws_security_group.raxxo_sg.id]
  key_name                    = aws_key_pair.raxxo_key.key_name
  associate_public_ip_address = true
  user_data_base64            = filebase64("installapps.sh")

  tags = {
    Name = "Raxxo-Ec2"
  }
}

# Output opcional para ver la IP
output "instance_public_ip" {
  value = aws_instance.raxxo_ec2.public_ip
}
