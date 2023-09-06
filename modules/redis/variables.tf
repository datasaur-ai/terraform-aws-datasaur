variable "vpc_id" {
  type        = string
  description = "VPC Id"
}

variable "subnet_ids" {
  type        = list(string)
  description = "subnet ids for subnet group"
}

variable "cluster_name" {
  description = "Cluster name"
}

variable "vpc_cidr_block" {
  description = "VPC Cidr block"
}

variable "owner" {
  type        = string
  description = "Environment name that will be set for this resource"
}

variable "environment" {
  type        = string
  description = "Environment name that will be set for this resource"
}

variable "redis_node_type" {
  type    = string
  default = "cache.r5.large"
}

variable "non_prod" {
  type    = bool
  default = false
}

variable "vanta_no_alert_reason" {
  type    = string
  default = null
}



