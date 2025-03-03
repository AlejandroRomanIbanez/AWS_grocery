# Variable for private subnet IDs
variable "subnet_ids" {
  description = "List of private subnet IDs for ASG instances"
  type        = list(string)
}

# Variable for launch template ID
variable "launch_template_id" {
  description = "ID of the launch template"
  type        = string
}

# Variable for launch template version
variable "launch_template_version" {
  description = "Version of the launch template"
  type        = string
}

# Variable for ALB target group ARN
variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}