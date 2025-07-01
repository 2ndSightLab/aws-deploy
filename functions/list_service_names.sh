#!/bin/bash
list_service_names(){
  local ENV_PROFILE=$1
  local REGION=$2
  
  if [ -z "$ENV_PROFILE" ]; then echo "$ENV_PROFILE not set in list_service_names" >&2; exit 1; fi
  if [ -z "$REGION" ]; then echo "$REGION not set in list_service_names" >&2; exit 1; fi
  
  aws cloudformation list-types --visibility PUBLIC --type RESOURCE --profile $ENV_PROFILE --region $REGION --output json | jq -r '.TypeSummaries[].TypeName' | grep -o 'AWS::[^:]*' | sed 's/AWS:://' | sort -u
}
