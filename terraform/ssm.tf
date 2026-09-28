################
# Ansible SSM S3 Bucket
################

resource "aws_s3_bucket" "ansible_ssm" {
  bucket_prefix = "django-ansible-ssm-"

  tags = {
    Name = "django-ansible-ssm"
  }
}