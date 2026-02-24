output "cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.this.arn
  sensitive   = true
}

output "cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = aws_ecs_task_definition.this.arn
  sensitive   = true
}

output "task_definition_family" {
  description = "The family of the ECS task definition"
  value       = aws_ecs_task_definition.this.family
}

output "task_execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  value       = aws_iam_role.task_execution_role.arn
  sensitive   = true
}

output "task_role_arn" {
  description = "The ARN of the ECS task role"
  value       = aws_iam_role.task_role.arn
  sensitive   = true
}

output "log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.this.name
}

output "exec_log_group_name" {
  description = "The name of the CloudWatch log group for ECS Exec session logs"
  value       = aws_cloudwatch_log_group.ecs_exec.name
}
