variable "region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block"
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "todo-container-app2"
    ManagedBy   = "Terraform"
  }
}

variable "subnets" {
  description = "Subnet configuration per AZ"
  type = map(object({
    public_cidr  = string
    private_cidr = string
  }))
}

variable "ecr_repository_name" {
  type        = string
  description = "ECR repository name"
}

variable "container_port" {
  type        = number
  description = "Port the container listens on"
  default     = 3000
}

variable "health_check_path" {
  type        = string
  description = "Health check path for ALB target group"
  default     = "/health"
}