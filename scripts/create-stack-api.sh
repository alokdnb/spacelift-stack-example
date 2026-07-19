#!/bin/bash

# Spacelift Stack Creation Script via GraphQL API
# Usage: ./scripts/create-stack-api.sh <api-token>

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <spacelift-api-token>"
    echo ""
    echo "To get your API token:"
    echo "  1. Log in to https://alokdnb.app.us.spacelift.io"
    echo "  2. Go to Settings → API → API Keys"
    echo "  3. Click 'Create API Key'"
    echo "  4. Copy the token and run: $0 <token>"
    exit 1
fi

API_TOKEN="$1"
SPACELIFT_INSTANCE="alokdnb"
ENDPOINT="https://${SPACELIFT_INSTANCE}.app.us.spacelift.io/graphql"

echo "Creating Spacelift stack..."
echo "Instance: $SPACELIFT_INSTANCE"
echo "Endpoint: $ENDPOINT"
echo ""

# Create the GraphQL mutation
QUERY=$(cat <<'EOF'
mutation CreateStack {
  stackCreate(
    input: {
      name: "spacelift-example-dev"
      description: "Example Spacelift stack using terraform-module-example"
      branch: "main"
      projectRoot: "."
      gitHub: {
        repository: "alokdnb/spacelift-stack-example"
      }
      terraform: {
        version: "1.5.0"
      }
      allowAutoApply: false
      autoRetry: false
    }
  ) {
    stack {
      id
      name
      slug
      repository {
        branch
        repository
      }
    }
  }
}
EOF
)

# Execute the mutation
RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  --data @- \
  "${ENDPOINT}" << PAYLOAD
{
  "query": $(echo "$QUERY" | jq -Rs .)
}
PAYLOAD
)

echo "Response:"
echo "$RESPONSE" | jq '.'

# Check for errors
if echo "$RESPONSE" | jq -e '.errors' > /dev/null; then
    echo ""
    echo "❌ Error creating stack:"
    echo "$RESPONSE" | jq '.errors'
    exit 1
fi

# Extract stack details
STACK_ID=$(echo "$RESPONSE" | jq -r '.data.stackCreate.stack.id')
STACK_NAME=$(echo "$RESPONSE" | jq -r '.data.stackCreate.stack.name')
STACK_SLUG=$(echo "$RESPONSE" | jq -r '.data.stackCreate.stack.slug')

echo ""
echo "✅ Stack created successfully!"
echo ""
echo "Stack Details:"
echo "  ID: $STACK_ID"
echo "  Name: $STACK_NAME"
echo "  Slug: $STACK_SLUG"
echo ""
echo "Next steps:"
echo "  1. Log in to: https://${SPACELIFT_INSTANCE}.app.us.spacelift.io"
echo "  2. Navigate to Stack: $STACK_NAME"
echo "  3. Configure AWS credentials in Settings → Secrets"
echo "  4. Create a new run: Stack → New Run → Plan"
echo "  5. Review and approve the plan"
echo ""
