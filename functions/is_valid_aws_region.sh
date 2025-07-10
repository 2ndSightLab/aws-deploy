#!/bin/bash
is_valid_aws_region() {

    validate_first_n_args_set 2  "$@"
    
    local REGION=$1
    local ENV_PROFILE=$2

    echo "Checking to see if $REGION is a valid region using $ENV_PROFILE"
    echo "Querying a known good region: us-east-1"
    
    # Fetch the list of valid AWS regions using us-east-1 so we know we're starting with a valid region
    # Presuming here the user has access to us-east-1. If you change this it should be hard-coded to a valid region.
    local aws_regions=$(aws ec2 describe-regions --query 'Regions[].RegionName' --profile $ENV_PROFILE --region us-east-1 --output text)
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to retrieve AWS region list." >&2
        exit
    fi
    
    echo "Valid regions: $aws_regions"
    echo "$aws_regions" | grep -qw "$REGION"

    if [ $? -eq 0 ]; then
        echo "REGION $REGION is valid"
        return 0
    else
        echo "REGION $REGION is not valid"
        exit 1
    fi
  
}
