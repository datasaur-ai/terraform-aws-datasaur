variable "project" {
  description = "Project Name"
}

variable "customer_name" {
  description = "Name of the customer"
}

variable "cluster_name" {
  description = "Name of the cluster that will be created"
}

variable "description" {
  description = "Description of these resources"
}


variable "owner" {
  description = "PIC Email Address"
}

variable "environment" {
  description = "Environment name that will be set for these resources"
}

variable "non_prod" {
  type    = bool
  default = false
}

variable "vpc_flow_log_cloudwatch_iam_role_arn" {
  description = "The ARN of the IAM role used when pushing logs to Cloudwatch log group"
}

variable "vpc_flow_log_cloudwatch_destination_arn" {
  description = "The ARN of the cloudwatch destination for VPC Flow Logs"
}

variable "vpc_private_subnets" {
  description = "IP addresses block for private subnets"
}

variable "vpc_public_subnets" {
  description = "IP addresses block for public subnets"
}

variable "vpc_cidr" {
  description = "VPC Cidr Block"
}

variable "node_group_worker_instance_types" {
    description = "Instance type of node worker"
    default = ["m5a.xlarge"]
}

variable "node_group_worker_max_size" {
    description = "Node group max size"
    default = 3
}

variable "node_group_worker_desired_size" {
    description = "Node group desired size"
    default = 2
}