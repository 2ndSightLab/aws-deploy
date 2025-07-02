#!/bin/bash -e
get_aws_account(){

  validate_first_n_args_set 1  "$@"

  local ENV_PROFILE="$1"

  echo $(aws sts get-caller-identity --query "Account" --profile $ENV_PROFILE --output text)
  
}
