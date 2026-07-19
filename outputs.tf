output "bucket_id" {
  description = "The ID of the created S3 bucket"
  value       = module.example_bucket.bucket_id
}

output "bucket_arn" {
  description = "The ARN of the created S3 bucket"
  value       = module.example_bucket.bucket_arn
}

output "bucket_region" {
  description = "The region of the created S3 bucket"
  value       = module.example_bucket.bucket_region
}

output "bucket_domain_name" {
  description = "The regional domain name of the S3 bucket"
  value       = module.example_bucket.bucket_domain_name
}

output "module_version" {
  description = "Reference to the terraform-module-example module"
  value       = "github.com/alokdnb/terraform-module-example@main"
}
