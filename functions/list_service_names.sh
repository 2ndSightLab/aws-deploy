#!/bin/bash
list_service_names(){

  validate_first_n_args_set 2  "$@"

  local ENV_PROFILE=$1
  local REGION=$2
  
  cmd="aws cloudformation list-types --visibility PUBLIC --type RESOURCE --profile $ENV_PROFILE --region $REGION --output json | jq -r '.TypeSummaries[].TypeName' | grep -o 'AWS::[^:]*' | sed 's/AWS:://' | sort -u"
  
  run_aws_cmd_with_retry $cmd
  
}
