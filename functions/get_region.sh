#!/bin/bash
get_region() {
    local region=""
    
    # Try to get region from AWS CLI configuration
    region=$(aws configure get region 2>/dev/null)
    
    # If still not found, try to get it from ECS task metadata
    if [ -z "$region" ] && [ ! -z "$ECS_CONTAINER_METADATA_URI_V4" ]; then
        region=$(curl -s ${ECS_CONTAINER_METADATA_URI_V4}/task 2>/dev/null | jq -r '.AvailabilityZone | .[:-1]' 2>/dev/null)
    fi
    
    # If still not found, try to get it from AWS_REGION environment variable
    if [ -z "$region" ] && [ ! -z "$AWS_REGION" ]; then
        region=$AWS_REGION
    fi
    
    # If region is still empty, exit with an error
    if [ -z "$region" ]; then
        echo "Error: Unable to determine AWS region" >&2
        return 1
    fi
    
    # Validate the region using the is_valid_aws_region function
    is_valid_aws_region "$region"
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # If we've made it here, the region is valid
    echo "$region"
    return 0
}
