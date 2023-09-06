variable "identifier" {
  description = "Name of the instance that will be created"
}

variable "db_name" {
  description = "DB Name"
}

variable "db_username" {
  description = "DB Username"
}

variable "db_instance_type" {
  description = "DB Instance Type"
}

variable "db_read_replica_instance_type" {
  description = "Read Replica DB Instance Type"
}

variable "db_multi_az" {
  description = "Is DB Multi AZ?"
}

variable "db_allocated_storage" {
  description = "Allocated Storage in GB"
}

variable "db_subnet_ids" {
  description = "Subnet ids for creating DB Subnet Group"
}

variable "parameter_group_name" {
  description = "parameter group name"
}

variable "parameter_group_family" {
  description = "parameter group family"
}

variable "vpc_security_group_ids" {
  description = "VPC Security group ids that will be set for resource"
}

variable "cluster_name" {
  description = "Cluster name"
}

variable "project" {
  description = "Project name"
}

variable "owner" {
  description = "Owner"
}

variable "engine_version" {
  description = "Engine Version"
}

variable "environment" {
  description = "Environment name that will be set for resource"
}

variable "non_prod" {
  type    = bool
  default = false
}

variable "vanta_no_alert_reason" {
  type    = string
  default = null
}

locals {
  tags = {
    Project               = var.project
    Environment           = var.environment
    VantaOwner            = var.owner
    VantaNonProd          = var.non_prod
    VantaDescription      = "Store application data"
    VantaContainsUserData = true
    VantaUserDataStored   = "Usernames. Emails. Passwords. User-generated documents."
    VantaContainsEPHI     = true
    VantaNoAlert          = var.vanta_no_alert_reason
  }

  engine                          = "mariadb"
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
}
