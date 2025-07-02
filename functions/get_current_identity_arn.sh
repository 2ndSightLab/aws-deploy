#!/bin/bash -e
get_current_identity_arn() {

    validate_first_n_args_set 1  "$@"
    
    local ENV_PROFILE="$1"
    
    local arn
    arn=$(aws sts get-caller-identity --query 'Arn' --profile $ENV_PROFILE --output text)
    arn=$(trim_spaces_and_quotes $arn)
    
    echo "$arn"
}
