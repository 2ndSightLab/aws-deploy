#!/bin/bash -e

is_valid_service_resource() {
  SERVICE_NAME="$1"
  RESOURCE_NAME="$2"
  ENV_PROFILE=$3
  REGION=$4

  if [ -z "$SERVICE_NAME" ]; then echo "$SERVICE_NAME not set in is_valid_service_resource" >&2; exit 1; fi
  if [ -z "$RESOURCE_NAME" ]; then echo "$RESOURCE_NAME not set in is_valid_service_resource" >&2; exit 1; fi
  if [ -z "$ENV_PROFILE" ]; then echo "$ENV_PROFILE not set in is_valid_service_resource" >&2; exit 1; fi
  if [ -z "$REGION" ]; then echo "$REGION not set in is_valid_service_resource" >&2; exit 1; fi

  RESOURCE_EXISTS=$(aws cloudformation list-types --visibility PUBLIC --type RESOURCE \
  --filters TypeNamePrefix="AWS::${SERVICE_NAME}::${RESOURCE_NAME}" \
  --query "TypeSummaries[?TypeName=='AWS::${SERVICE_NAME}::${RESOURCE_NAME}'].TypeName" \
  --profile $ENV_PROFILE --region $REGION \
  --output text)
  
  if [ -z "$RESOURCE_EXISTS" ]; then
    echo "Error: Invalid resource name '$RESOURCE_NAME' for service '$SERVICE_NAME'"
    exit
  else
     echo "Resource name '$RESOURCE_NAME' for service '$SERVICE_NAME' exists"
  fi
}
