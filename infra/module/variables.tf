variable "aws_env" {
  type = string
  description = "the environment being deployed to in AWS"
}

variable "aws_region" {
  type        = string
  description = "Region of AWS being deployed to"
}

variable "aws_tf_rel_role_name" {
  type        = string
  description = "The role name responsible for terraform release processes"
  sensitive   = true
}
