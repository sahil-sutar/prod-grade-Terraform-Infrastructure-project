provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "AWS-Enterprise-IaC"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# 1. VPC Module
module "vpc" {
  source                   = "../../modules/vpc"
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = var.availability_zones
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
}

# 2. Security Module
module "security" {
  source      = "../../modules/security"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

# 3. Compute Module (ALB + ASG)
module "compute" {
  source                = "../../modules/compute"
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_app_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  app_security_group_id = module.security.app_security_group_id
}

# 4. Database Module (RDS)
module "database" {
  source                = "../../modules/database"
  environment           = var.environment
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  db_security_group_id  = module.security.db_security_group_id
  db_password           = var.db_password
}