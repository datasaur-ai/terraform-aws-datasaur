variable "project" {
  description = "Project Name"
}

variable "bucket_name" {
  description = "Name of the bucket that will be created"
}

variable "environment" {
  description = "Environment name that will be set for this bastion host"
}

variable "non_prod" {
  type    = bool
  default = false
}

variable "mfa_delete" {
  type    = bool
  default = false
}

variable "vanta_no_alert_reason" {
  type    = string
  default = null
}

locals {
  owner = "hartono@datasaur.ai"
  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    Project     = var.project

    VantaOwner            = local.owner
    VantaNonProd          = var.non_prod
    VantaDescription      = "Store private files"
    VantaContainsUserData = true
    VantaUserDataStored   = "Private documents"
    VantaContainsEPHI     = true
    VantaNoAlert          = var.vanta_no_alert_reason
  }
  inventory_tags = {
    Name        = "${var.bucket_name}-inventory"
    Environment = var.environment
    Project     = var.project

    VantaOwner            = local.owner
    VantaNonProd          = var.non_prod
    VantaDescription      = "Store private files logs"
    VantaContainsUserData = false
    VantaUserDataStored   = null
    VantaContainsEPHI     = false
    VantaNoAlert          = var.vanta_no_alert_reason
  }
  log_bucket_tags = {
    Project     = var.project
    Name        = var.bucket_name
    Environment = var.environment

    VantaOwner            = local.owner
    VantaNonProd          = var.non_prod
    VantaDescription      = "Store ${var.bucket_name} log files"
    VantaContainsUserData = false
    VantaUserDataStored   = null
    VantaContainsEPHI     = false
    VantaNoAlert          = var.vanta_no_alert_reason
  }
}
