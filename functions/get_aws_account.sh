#!/bin/bash -e
get_aws_account(){

  validate_first_n_args_set 2  "$@"

  local ENV_PROFILE="$1"
  local REGION="$2"

  echo $(aws sts get-caller-identity --query "Account" --profile $ENV_PROFILE --region $REGION --output text)
  
}
