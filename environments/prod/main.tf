provider "aws" {
  region = "ap-southeast-2"
}

terraform {
  backend "s3" {
    bucket = "my-terraform-shared-state"
    key    = "realworldapp/prod/state/terraform.tfstate"
    region = "ap-southeast-2"

    dynamodb_table = "terraform-shared-state-locks"
    encrypt        = true
  }
}

locals {
  project_name = "realworldapp"
  environment  = "prod"
  region       = "ap-southeast-2"
  prefix       = "${local.project_name}-${local.environment}"
}

module "vpc" {
  source = "../../modules/networking"

  region       = local.region
  project_name = local.project_name
  environment  = local.environment

  cidr_block = "10.0.0.0/16"
  public     = ["10.0.101.0/24", "10.0.102.0/24"]
  private    = ["10.0.11.0/24", "10.0.12.0/24"]
}

module "database" {
  source = "../../modules/rds-aurora"

  project_name = local.project_name
  environment  = local.environment

  cluster_name           = "${local.prefix}-db-postgres"
  postgres_version       = "13.4"
  instance_class         = "db.t4g.medium"
  vpc_id                 = module.vpc.vpc_id
  database_ingress_ports = [5432]
  subnet_cidr               = ["10.0.21.0/24", "10.0.22.0/24"]
  cluster_instances = {
    one = {
      publicly_accessible = true
    }
    two = {
      identifier     = "static-member-1"
      instance_class = "db.t4g.medium"
    }
  }
  ecs_sg_id            = ""
  db_name = local.project_name
  enable_direct_access = true
  your_cidr = var.your_cidr
  internet_gateway_id = module.vpc.internet_gateway_id
}