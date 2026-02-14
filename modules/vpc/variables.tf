variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, stg, prod)"
  type        = string
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}

variable "subnets" {
  description = "Subnet configuration per AZ"
  type = map(object({
    public_cidr  = string
  }))
}