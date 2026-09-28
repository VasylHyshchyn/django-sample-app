################
# ALB Security Group
################

resource "aws_security_group" "alb" {
  name        = "django-alb-sg"
  description = "Security group for Django ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "django-alb-sg"
  }
}

################
# Application Load Balancer
################

resource "aws_lb" "main" {
  name               = "django-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public.id,
    aws_subnet.public_2.id
  ]

  tags = {
    Name = "django-alb"
  }
}

################
# ALB Target Group
################

resource "aws_lb_target_group" "web" {
  name     = "django-web-tg"
  port     = 80
  protocol = "HTTP"

  vpc_id = aws_vpc.main.id

  health_check {
    enabled  = true
    protocol = "HTTP"
    path     = "/"
    port     = "traffic-port"
  }

  tags = {
    Name = "django-web-tg"
  }
}

################
# Web Target Attachments
################

resource "aws_lb_target_group_attachment" "web" {
  for_each = aws_instance.web

  target_group_arn = aws_lb_target_group.web.arn
  target_id        = each.value.id
  port             = 80
}

################
# ALB Listener
################

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}