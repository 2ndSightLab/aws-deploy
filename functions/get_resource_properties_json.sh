#!/bin/bash -e
get_resource_properties_json(){
  SCHEMA="$1"
  echo "hello"
  properties_json=$(jq -r 'if type == "string" then fromjson else . end | .properties' <<< "$SCHEMA") 
  echo $properties_json
  
}
