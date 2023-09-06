locals {
  username = "vulcan"
}


variable "project" {
  description = "Project Name"
}

variable "environment" {
  description = "Environment name that will be set for this S3 bucket"
}

variable "instance_type" {
  description = "Broker Instance Type"
  default = "mq.m5.large"
}

variable "broker_name" {
  description = "Broker Name"
}

variable "deployment_mode" {
  description = "Deployment Mode: SINGLE_INSTANCE or CLUSTER_MULTI_AZ"
  default = "CLUSTER_MULTI_AZ"
}

variable "security_group_ids" {
  type = list(string)
  description = "Security group's id list"
}

variable "subnet_ids" {
  type = list(string)
  description = "Subnet id list"
}