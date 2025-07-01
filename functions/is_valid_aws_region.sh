#!/bin/bash
is_valid_aws_region() {
    local region_name=$1
    local ENV_PROFILE=$2
    local REGION=$3
    
    if [ -z "$ENV_PROFILE" ]; then echo "$ENV_PROFILE not set in is_valid_aws_region"; fi
    if [ -z "$REGION" ]; then echo "$REGION not set in is_valid_aws_region"; fi
    
    # Check if region name is provided
    if [ -z "$region_name" ]; then
        echo "Error: Region name must be provided." >&2
        return 1
    fi
    
    # Fetch the list of valid AWS regions using us-east-1 so we know we're starting with a valid region
    # Presuming here the user has access to us-east-1. If you change this it should be hard-coded to a valid region.
    local aws_regions=$(aws ec2 describe-regions --query 'Regions[].RegionName' --region us-east-1 --output text 2>/dev/null)
    
    # Check if aws command failed
    if [ $? -ne 0 ]; then
        echo "Error: Failed to retrieve AWS region list." >&2
        return 1
    fi
    
    # Check if the region name is in the list
    if [[ $aws_regions =~ (^|[[:space:]])$region_name($|[[:space:]]) ]]; then
        return 0  # Valid region
    else
        echo "Error: '$region_name' is not a valid AWS region." >&2
        return 1  # Invalid region
    fi
}
