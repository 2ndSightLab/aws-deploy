#!/bin/bash
get_region() {

    validate_first_n_args_set 1  "$@"
    
    local ENV_PROFILE="$1"
    
    local REGION=""
    
    # Try to get region from AWS CLI configuration
    REGION=$(aws configure get region --profile $ENV_PROFILE)
    
    # If still not found, try to get it from ECS task metadata
    if [ -z "$REGION" ] && [ ! -z "$ECS_CONTAINER_METADATA_URI_V4" ]; then
        region=$(curl -s ${ECS_CONTAINER_METADATA_URI_V4}/task 2>/dev/null | jq -r '.AvailabilityZone | .[:-1]' 2>/dev/null)
    fi
    
    # If still not found, try to get it from AWS_REGION environment variable
    if [ -z "$REGION" ] && [ ! -z "$AWS_REGION" ]; then
        REGION=$AWS_REGION
    fi
    
    # If region is still empty, exit with an error
    if [ -z "$REGION" ]; then
        echo "Error: Unable to determine AWS region" >&2
        return 1
    fi
    
    # Validate the region using the is_valid_aws_region function
    #is_valid_aws_region "$region"
    #if [ $? -ne 0 ]; then
    #    return 1
    #fi
    
    # If we've made it here, the region is valid
    echo "$REGION"
    return 0
}
