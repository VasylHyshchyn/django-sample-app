################
# EC2 SSM Role
################

resource "aws_iam_role" "ec2_ssm" {
  name = "django-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "django-ec2-ssm-role"
  }
}


################
# SSM Policy Attachment
################

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


################
# EC2 Instance Profile
################

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "django-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm.name
}