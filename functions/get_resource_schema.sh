#!/bin/bash -e
#resource_type: "AWS::$SERVICE_NAME::$RESOURCE_NAME"
get_resource_schema(){

  validate_first_n_args_set 3  "$@"

  local resource_type="$1"
  local ENV_PROFILE=$2
  local REGION=$3

  schema=$(aws cloudformation describe-type --type RESOURCE --type-name "$resource_type" --query 'Schema' --profile $ENV_PROFILE --region $REGION --output json)
  echo $schema
}
