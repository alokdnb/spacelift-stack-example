variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "spacelift-example-bucket"

  validation {
    condition     = can(regex("^[a-z0-9.-]+$", var.bucket_name))
    error_message = "Bucket name must contain only lowercase letters, numbers, hyphens, and periods."
  }
}

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "block_public_access" {
  description = "Block public access to the S3 bucket"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "spacelift-example"
    Terraform   = "true"
  }
}

variable "spacelift_environment" {
  description = "Spacelift environment name"
  type        = string
  default     = "dev"
}
