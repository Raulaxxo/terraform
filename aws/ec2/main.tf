provider "aws" {
  profile = "Raxxo"
  region  = "us-east-1"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_subnets" "raxxo_subnets" {
  filter {
    name   = "vpc-id"
    values = ["vpc-036865d4d83d6070f"]
  }
}

resource "aws_key_pair" "raxxo_key" {
  key_name   = "raxxo-key"
  public_key = file("~/.ssh/Raxxo/raxxokey.pub")
}

resource "aws_security_group" "raxxo_sg" {
  name        = "RaxxoAllowSSH"
  description = "Allow SSH"
  vpc_id      = "vpc-036865d4d83d6070f"

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

resource "aws_instance" "raxxo_ec2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnets.raxxo_subnets.ids[0]
  vpc_security_group_ids = [aws_security_group.raxxo_sg.id]
  key_name               = aws_key_pair.raxxo_key.key_name
  associate_public_ip_address = true
  user_data_base64 = filebase64("installapps.sh")

  tags = {
    Name = "Raxxo-Ec2"
  }
}
