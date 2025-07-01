#!/bin/bash -e
#resource_type: "AWS::$SERVICE_NAME::$RESOURCE_NAME"
get_resource_schema(){
  local resource_type="$1"
  local ENV_PROFILE="$2"
  
  schema=$(aws cloudformation describe-type --type RESOURCE --type-name "$resource_type" --query 'Schema' --profile $ENV_PROFILE --output json)
  echo $schema
}
