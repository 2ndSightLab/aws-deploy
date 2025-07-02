#!/bin/bash -e
get_aws_account(){

  validate_first_n_args_set 2  "$@"

  local ENV_PROFILE="$3"
  local REGION="$4"

  echo $(aws sts get-caller-identity --profile your-profile-name --query "Account" --output text)
  
}
