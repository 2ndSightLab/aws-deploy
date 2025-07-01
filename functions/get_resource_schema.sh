#!/bin/bash -e
#resource_type: "AWS::$SERVICE_NAME::$RESOURCE_NAME"
get_resource_schema(){
  local resource_type="$1"
  local ENV_PROFILE=$2
  
  if [ -z "$ENV_PROFILE" ]; then echo "$ENV_PROFILE not set in get_resource_schema"; fi
  
  schema=$(aws cloudformation describe-type --type RESOURCE --type-name "$resource_type" --query 'Schema' --profile $ENV_PROFILE --output json)
  echo $schema
}
