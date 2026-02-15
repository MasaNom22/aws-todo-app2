terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  backend "s3" {}

}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr_block = var.vpc_cidr_block
  environment    = var.environment
  project_name   = var.project_name
  common_tags    = var.common_tags
  subnets        = var.subnets
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name = var.ecr_repository_name
  project_name    = var.project_name
  environment     = var.environment
  common_tags     = var.common_tags
}

module "ecs" {
  source     = "../../modules/ecs"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = var.common_tags
}
