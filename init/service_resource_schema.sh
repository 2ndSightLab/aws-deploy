#!/bin/bash -e

echo "Get service resource schema"
RESOURCE_TYPE="AWS::$SERVICE_NAME::$RESOURCE_NAME"

SCHEMA=$(get_resource_schema $RESOURCE_TYPE $ENV_PROFILE $REGION)
if [ -z "$SCHEMA" ]; then echo "Error: No schmea returned for resource type: $RESOURCE_TYPE"; exit 1; fi

SCHEMA_B64=$(echo "$SCHEMA" | base64)

