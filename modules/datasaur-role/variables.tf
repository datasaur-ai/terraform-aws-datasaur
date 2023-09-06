variable "bucket_resources" {
  type = list(string)
}

variable "environment" {
  description = "Environment name that will be set for resource"
}

variable "max_session_duration" {
  description = "Maximum session duration"
  type        = number
  default     = 3600
}

variable "cluster_name" {
  description = "EKS Cluster Name"
}

variable "project" {
  description = "Project name"
}

variable "use_sagemaker" {
  description = "Fill this if you use AWS textract"
  type        = bool
  default     = false
}

variable "use_textract" {
  description = "Fill this if you use AWS textract"
  type        = bool
  default     = true
}

variable "use_bucket_accessor" {
  description = "Fill this if you use bucket accessor"
  type        = bool
  default     = true
}
