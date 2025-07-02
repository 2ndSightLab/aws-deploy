#!/bin/bash -e
is_valid_aws_profile() {
     
     validate_first_n_args_set 1  "$@"
     
    local profile="$1"
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI is not installed or not in PATH"
        return 2
    fi
    
    # Check if the profile exists in AWS config files
    if aws configure list-profiles 2>/dev/null | grep -q "^${profile}$"; then
        return 0
    else
        return 1
    fi
}
