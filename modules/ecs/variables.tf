variable "project_name" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}

variable "ecr_repository_url" {
  type        = string
  description = "ECR repository URL for the container image"
}

variable "container_name" {
  type        = string
  description = "Name of the container"
  default     = "todo-app"
}

variable "container_port" {
  type        = number
  description = "Port the container listens on"
  default     = 80
}

variable "image_tag" {
  type        = string
  description = "Container image tag"
  default     = "latest"
}

variable "task_cpu" {
  type        = number
  description = "CPU units for the task (256 = 0.25 vCPU)"
  default     = 256
}

variable "task_memory" {
  type        = number
  description = "Memory in MiB for the task"
  default     = 512
}

variable "log_retention_in_days" {
  type        = number
  description = "CloudWatch log group retention in days"
  default     = 30
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "desired_count" {
  type        = number
  description = "Desired number of ECS tasks"
  default     = 1
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for ECS tasks"
}

variable "ecs_security_group_id" {
  type        = string
  description = "Security group ID for ECS tasks (created externally)"
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the ALB target group"
}

variable "db_secret_arn" {
  type        = string
  description = "ARN of Secrets Manager secret containing DB credentials"
  default     = ""
}

variable "enable_db_secret_access" {
  type        = bool
  description = "Enable DB secret injection and IAM access policy for ECS task execution role"
  default     = false
}

variable "node_env" {
  type        = string
  description = "NODE_ENV value passed to the container"
  default     = "production"
}

variable "db_ssl" {
  type        = string
  description = "DB_SSL value passed to the container"
  default     = "true"
}

variable "secrets_kms_key_arn" {
  type        = string
  description = "KMS key ARN used by Secrets Manager secret. Empty when using AWS managed key."
  default     = ""
}
