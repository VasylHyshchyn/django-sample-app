################
# ALB
################

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}


################
# Web Instances
################

output "web_instance_ids" {
  description = "Web EC2 instance IDs"
  value       = {
    for name, instance in aws_instance.web :
    name => instance.id
  }
}


output "web_private_ips" {
  description = "Private IPs of web EC2 instances"
  value       = {
    for name, instance in aws_instance.web :
    name => instance.private_ip
  }
}


################
# Database Instance
################

output "db_instance_id" {
  description = "Database EC2 instance ID"
  value       = aws_instance.db.id
}


output "db_private_ip" {
  description = "Private IP of database EC2"
  value       = aws_instance.db.private_ip
}

################
# Ansible SSM Bucket
################

output "ansible_ssm_bucket" {
  description = "S3 bucket used by Ansible SSM connection"
  value       = aws_s3_bucket.ansible_ssm.bucket
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"

  content = <<-EOT
[web]
%{ for name, instance in aws_instance.web ~}
${name} ansible_host=${instance.id}
%{ endfor ~}

[db]
db_server ansible_host=${aws_instance.db.id} db_host=${aws_instance.db.private_ip}

[all:vars]
ansible_connection=community.aws.aws_ssm
ansible_aws_ssm_region=${var.aws_region}
ansible_aws_ssm_bucket_name=${aws_s3_bucket.ansible_ssm.bucket}
ansible_python_interpreter=/usr/bin/python3
EOT
}