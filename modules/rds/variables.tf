variable "vpc_id" {}
variable "private_subnets" { type = list(string) }
variable "environment" {}
variable "db_engine" {}
variable "db_engine_version" {}
variable "db_instance_class" {}
variable "db_username" {}
variable "db_password" { sensitive = true }
variable "db_name" { default = "appdb" }
variable "db_port" { default = 3306 }
variable "allocated_storage" { default = 20 }
variable "allowed_sg_ids" { type = list(string) } # security groups allowed to connect (pass app sg id)
