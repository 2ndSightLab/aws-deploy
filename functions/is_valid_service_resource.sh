#!/bin/bash -e

is_valid_service_resource() {
  SERVICE_NAME="$1"
  RESOURCE_NAME="$2"

  # Check if all parameters are provided
  if [ -z "$SERVICE_NAME" ] || [ -z "$RESOURCE_NAME" ] ; then
        echo "Error: All parameters (SERVICE_NAME, RESOURCE_NAME) must be provided." >&2
        exit
  fi

  RESOURCE_EXISTS=$(aws cloudformation list-types --visibility PUBLIC --type RESOURCE \
  --filters TypeNamePrefix="AWS::${SERVICE_NAME}::${RESOURCE_NAME}" \
  --query "TypeSummaries[?TypeName=='AWS::${SERVICE_NAME}::${RESOURCE_NAME}'].TypeName" \
  --output text)
  
  if [ -z "$RESOURCE_EXISTS" ]; then
    echo "Error: Invalid resource name '$RESOURCE_NAME' for service '$SERVICE_NAME'"
    exit
  else
     echo "Resource name '$RESOURCE_NAME' for service '$SERVICE_NAME' exists"
  fi
}
