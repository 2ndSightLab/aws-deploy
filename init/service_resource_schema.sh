#!/bin/bash -e

echo "Get service resource type"
RESOURCE_TYPE="AWS::$SERVICE_NAME::$RESOURCE_NAME"
echo "RESOURCE_TYPE: $RESOURCE_TYPE"

echo "get the schema"
SCHEMA=$(get_resource_schema $RESOURCE_TYPE $ENV_PROFILE $REGION)
if [ -z "$SCHEMA" ]; then echo "Error: No schmea returned for resource type: $RESOURCE_TYPE"; exit 1; fi

echo "SCHEMA:"
echo "$SCHEMA | jq ."

SCHEMA_B64=$(echo $SCHEMA | base64)

