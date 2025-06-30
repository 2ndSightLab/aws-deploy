#!/bin/bash -e
#resource_type: "AWS::$SERVICE_NAME::$RESOURCE_NAME"
get_resource_schema(){
  resource_type="$1"
  
  schema=$(aws cloudformation describe-type --type RESOURCE --type-name "$resource_type" --query 'Schema' --output json)
  echo $schema
}
