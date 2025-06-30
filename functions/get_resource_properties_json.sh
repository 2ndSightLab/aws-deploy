#!/bin/bash -e
get_resource_properties_json_from(){
  SCHEMA="$1"
  echo $(jq -r 'fromjson | .properties' <<< "$SCHEMA")
}
