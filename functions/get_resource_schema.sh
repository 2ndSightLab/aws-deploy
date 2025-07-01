#!/bin/bash -e
#resource_type: "AWS::$SERVICE_NAME::$RESOURCE_NAME"
get_resource_schema(){
  local resource_type="$1"
  local ENV_PROFILE=$2
  local REGION=$3

  if [ -z "$ENV_PROFILE" ]; then echo "$ENV_PROFILE not set in deploy_cloudformation_stack" >&2; exit 1; fi
  if [ -z "$REGION" ]; then echo "$REGION not set in deploy_cloudformation_stack" >&2; exit 1; fi

  schema=$(aws cloudformation describe-type --type RESOURCE --type-name "$resource_type" --query 'Schema' --profile $ENV_PROFILE --region $REGION --output json)
  echo $schema
}
