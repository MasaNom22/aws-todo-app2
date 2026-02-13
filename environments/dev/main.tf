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
}
