package spacelift

# Cost optimization policy
# Disabled by default but can be enabled for cost management

# Discourage unused resources
warn["Untagged resource detected"] {
	not input.resource.tags
}

# Recommend smaller instance types
warn["Consider using smaller instance type"] {
	input.resource_type == "aws_instance"
	instance_size := input.instance_type
	instance_size in ["c5.2xlarge", "c5.4xlarge", "c5.9xlarge"]
}

# Recommend spot instances for development
recommend["Use spot instances in dev/test environments"] {
	input.environment in ["dev", "test"]
	input.resource_type == "aws_instance"
	not input.resource.spot_price
}

# Recommend lifecycle rules for S3
recommend["Enable S3 lifecycle rules for storage optimization"] {
	input.resource_type == "aws_s3_bucket"
	not input.resource.lifecycle_rule
}

# Flag resources without encryption
warn["Consider enabling encryption"] {
	input.resource_type in ["aws_ebs_volume", "aws_rds_instance"]
	not input.resource.encrypted
}
