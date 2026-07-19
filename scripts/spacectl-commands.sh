#!/bin/bash

# Common spacectl commands for managing the stack
# Source this file to load functions: source scripts/spacectl-commands.sh

STACK_NAME="spacelift-example-dev"

# Get stack information
stack_info() {
    echo "Getting stack information for: $STACK_NAME"
    spacectl stack describe "$STACK_NAME"
}

# Create a plan
stack_plan() {
    echo "Creating plan for: $STACK_NAME"
    RUN_ID=$(spacectl run create "$STACK_NAME" --plan | jq -r '.id')
    echo "Plan created with Run ID: $RUN_ID"
    echo ""
    echo "View in Spacelift UI:"
    echo "  https://alokdnb.app.us.spacelift.io/stack/$STACK_NAME/run/$RUN_ID"
}

# Approve last run
stack_approve() {
    echo "Getting last run for: $STACK_NAME"
    LAST_RUN=$(spacectl run list "$STACK_NAME" --limit 1 | jq -r '.[0].id')
    echo "Approving run: $LAST_RUN"
    spacectl run approve "$LAST_RUN"
}

# Apply changes
stack_apply() {
    echo "Applying changes for: $STACK_NAME"
    LAST_RUN=$(spacectl run list "$STACK_NAME" --limit 1 | jq -r '.[0].id')
    echo "Applying run: $LAST_RUN"
    spacectl run apply "$LAST_RUN"
}

# Destroy infrastructure
stack_destroy() {
    echo "⚠️  WARNING: This will destroy all infrastructure managed by this stack"
    read -p "Continue? (yes/no): " CONFIRM
    if [ "$CONFIRM" = "yes" ]; then
        echo "Creating destroy run for: $STACK_NAME"
        spacectl run create "$STACK_NAME" --destroy
    else
        echo "Destroy cancelled"
    fi
}

# Set environment variable
stack_set_var() {
    VAR_NAME=$1
    VAR_VALUE=$2
    if [ -z "$VAR_NAME" ] || [ -z "$VAR_VALUE" ]; then
        echo "Usage: stack_set_var <name> <value>"
        return 1
    fi
    echo "Setting $VAR_NAME=$VAR_VALUE for $STACK_NAME"
    spacectl stack set-var "$STACK_NAME" --name "$VAR_NAME" --value "$VAR_VALUE" --env
}

# Get stack variables
stack_list_vars() {
    echo "Listing variables for: $STACK_NAME"
    spacectl stack show "$STACK_NAME" | jq '.environment'
}

# List recent runs
stack_runs() {
    LIMIT=${1:-10}
    echo "Listing last $LIMIT runs for: $STACK_NAME"
    spacectl run list "$STACK_NAME" --limit "$LIMIT" | jq '.[] | {id, status, created_at}'
}

# Get run details
stack_run_details() {
    RUN_ID=$1
    if [ -z "$RUN_ID" ]; then
        echo "Usage: stack_run_details <run-id>"
        return 1
    fi
    echo "Getting details for run: $RUN_ID"
    spacectl run describe "$RUN_ID" | jq '.'
}

# Retry last run
stack_retry() {
    echo "Getting last run for: $STACK_NAME"
    LAST_RUN=$(spacectl run list "$STACK_NAME" --limit 1 | jq -r '.[0].id')
    echo "Retrying run: $LAST_RUN"
    spacectl run retry "$LAST_RUN"
}

# Show menu
stack_menu() {
    echo ""
    echo "Spacelift Stack Commands for: $STACK_NAME"
    echo "=============================================="
    echo ""
    echo "Available functions:"
    echo "  stack_info          - Get stack information"
    echo "  stack_plan          - Create a terraform plan"
    echo "  stack_approve       - Approve last run"
    echo "  stack_apply         - Apply changes"
    echo "  stack_destroy       - Destroy infrastructure"
    echo "  stack_set_var       - Set environment variable"
    echo "  stack_list_vars     - List stack variables"
    echo "  stack_runs          - List recent runs"
    echo "  stack_run_details   - Get run details"
    echo "  stack_retry         - Retry last run"
    echo ""
    echo "Example usage:"
    echo "  stack_plan"
    echo "  stack_set_var AWS_REGION us-west-2"
    echo "  stack_runs 5"
    echo ""
}

# Print menu on load
stack_menu
