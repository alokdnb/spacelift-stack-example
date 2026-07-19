terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      var.common_tags,
      {
        ManagedBy = "Spacelift"
      }
    )
  }
}

module "example_bucket" {
  source = "github.com/alokdnb/terraform-module-example?ref=main"

  bucket_name         = var.bucket_name
  enable_versioning   = var.enable_versioning
  block_public_access = var.block_public_access

  common_tags = merge(
    var.common_tags,
    {
      Module = "terraform-module-example"
    }
  )
}
