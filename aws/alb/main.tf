provider "aws" {
  region  = "us-east-1"
  profile = "Raxxo"
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Permite trafico HTTP al ALB"
  vpc_id      = "vpc-0005283161467b1c6"

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_lb" "app_lb" {
  name               = "raxxo-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    "subnet-0d5fcebab7f080801",
    "subnet-008da362eeb9a9c3f"
  ]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "raxxo-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0005283161467b1c6"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "app_instance" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = "i-0d2440618532af099"
  port             = 80
}

output "alb_dns_name" {
  description = "URL pública del Load Balancer"
  value       = aws_lb.app_lb.dns_name
}
