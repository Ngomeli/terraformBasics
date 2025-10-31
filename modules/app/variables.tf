variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "environment" {}
variable "app_ami" {}
variable "instance_type" { default = "t3.micro" }
variable "ssh_key_name" {}
variable "instance_profile_name" { default = "" } # optional IAM instance profile for instance permissions (S3, CloudWatch, etc)
variable "desired_capacity" { default = 2 }
variable "min_size" { default = 1 }
variable "max_size" { default = 3 }
variable "app_port" { default = 80 }
variable "health_check_path" { default = "/" }
variable "admin_cidr" { default = "0.0.0.0/0" } # tighten to your IP
variable "user_data" { default = "" }
