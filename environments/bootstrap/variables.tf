variable "region" {
  type        = string
  description = "AWS region"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)

}
