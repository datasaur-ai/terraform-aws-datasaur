variable "project" {
  description = "Project Name"
}

variable "bucket_name" {
  description = "Name of the bucket that will be created"
}

variable "allowed_origins" {
  type        = list(string)
  description = "Allowed origins"
  default     = ["*datasaur.ai"]
}

variable "environment" {
  description = "Environment name that will be set for this S3 bucket"
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
  owner = "karol@datasaur.ai"
  tags = {
    Name                  = var.bucket_name
    Environment           = var.environment
    Project               = var.project

    VantaOwner            = local.owner
    VantaNonProd          = var.non_prod
    VantaDescription      = "Store public files"
    VantaContainsUserData = false
    VantaContainsEPHI     = false
    VantaNoAlert          = var.vanta_no_alert_reason
  }
}
