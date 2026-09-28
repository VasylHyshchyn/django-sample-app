################
# Web Security Group
################

resource "aws_security_group" "web" {
  name        = "django-web-sg"
  description = "Security group for Django web servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = var.http_port
    to_port         = var.http_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "django-web-sg"
  }
}

################
# Database Security Group
################

resource "aws_security_group" "db" {
  name        = "django-db-sg"
  description = "Security group for PostgreSQL"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from web servers"
    from_port       = var.postgres_port
    to_port         = var.postgres_port
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "django-db-sg"
  }
}

################
# Ubuntu AMI
################

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = [var.ubuntu_ami_name_pattern]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

################
# Web EC2
################

resource "aws_instance" "web" {
  for_each = {
    web_1 = aws_subnet.private_1.id
    web_2 = aws_subnet.private_2.id
  }

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id = each.value

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name

  tags = {
    Name = "django-${each.key}"
    Role = "web"
  }
}

################
# Database EC2
################

resource "aws_instance" "db" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.private_1.id

  vpc_security_group_ids = [
    aws_security_group.db.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name

  tags = {
    Name = "django-db"
    Role = "db"
  }
}