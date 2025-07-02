#!/bin/bash -e
get_current_identity_arn() {

    validate_first_n_args_set 2  "$@"
    
    local ENV_PROFILE="$1"
    local REGION="$2"
    
    local arn
    arn=$(aws sts get-caller-identity --query 'Arn' --profile $ENV_PROFILE --region $REGION --output text)
    
    echo "$arn"
}
