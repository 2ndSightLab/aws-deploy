#!/bin/bash -e

is_valid_service_resource() {

  validate_first_n_args_set 4  "$@"

  SERVICE_NAME="$1"
  RESOURCE_NAME="$2"
  ENV_PROFILE=$3
  REGION=$4

  echo "Check to see if $RESOURCE_NAME is a valid resource for service $SERVICE_NAME in region $REGION"
  
  cmd="aws cloudformation list-types --visibility PUBLIC --type RESOURCE \
  --filters TypeNamePrefix="AWS::${SERVICE_NAME}::${RESOURCE_NAME}" \
  --query \"TypeSummaries[?TypeName=='AWS::${SERVICE_NAME}::${RESOURCE_NAME}'].TypeName\" \
  --profile $ENV_PROFILE --region $REGION \
  --output text"

  RESOURCE_EXISTS=$(run_aws_cmd_with_retry $cmd)
   
  if [ -z "$RESOURCE_EXISTS" ]; then
    echo "Error: Invalid resource name '$RESOURCE_NAME' for service '$SERVICE_NAME'"
    exit
  else
     echo "Resource name '$RESOURCE_NAME' for service '$SERVICE_NAME' exists"
  fi
}
