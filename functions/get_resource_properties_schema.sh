#!/bin/bash -e
get_resource_property_schema(){
  schema=$(aws cloudformation describe-type --type RESOURCE --type-name "$resource_type" --query 'Schema' --output text)
  echo $schema
}
