module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs = var.azs
  environment = var.environment
}

module "app" {
  source = "./modules/app"
  vpc_id = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  environment = var.environment
  app_ami = var.app_ami
  instance_type = var.app_instance_type
  ssh_key_name = var.ssh_key_name
  admin_cidr = "x.x.x.x/32" # change to your IP
  instance_profile_name = "" # optional
}

module "rds" {
  source = "./modules/rds"
  vpc_id = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  environment = var.environment
  db_engine = var.db_engine
  db_engine_version = var.db_engine_version
  db_instance_class = var.db_instance_class
  db_username = var.db_username
  db_password = var.db_password
  allowed_sg_ids = [module.app.app_sg_id] # you might need to export app sg id in module app outputs
}
