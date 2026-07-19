package spacelift

# Access control policy for spacelift-example-dev stack
# This policy enforces who can perform which actions on the stack

# Default deny
default allow = false

# Allow admins to perform any action
allow {
	input.user.role == "admin"
}

# Allow stack admins to plan and apply
allow {
	input.user.role == "stack_admin"
	input.action in ["plan", "apply"]
}

# Allow reviewers to view and comment
allow {
	input.user.role == "reviewer"
	input.action in ["view", "comment"]
}

# Enforce environment-specific rules
deny["Cannot destroy in production"] {
	input.stack.environment == "production"
	input.action == "destroy"
}

# Require approval for apply actions
deny["Apply requires approval"] {
	input.action == "apply"
	not input.approved
	input.stack.environment in ["production", "staging"]
}

# Cost control - warn on large resource creation
warn["Large instance type requested"] {
	input.resource_type == "aws_instance"
	input.instance_type in ["c5.4xlarge", "c5.9xlarge", "r5.4xlarge", "r5.8xlarge"]
}
