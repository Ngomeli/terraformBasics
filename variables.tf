variable "region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24","10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24","10.0.11.0/24"]
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a","us-east-1b"]
}

variable "app_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "app_ami" {
  description = "AMI for app nodes (must be valid in the region)."
  type        = string
  default     = "ami-080c353f4798a202f" # example (change)
}

variable "ssh_key_name" {
  type    = string
  default = "my-keypair"
}

variable "db_username" {
  type    = string
  default = "appuser"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_engine" {
  default = "mysql"
}

variable "db_engine_version" {
  default = "8.0"
}

variable "db_instance_class" {
  default = "db.t3.micro"
}
