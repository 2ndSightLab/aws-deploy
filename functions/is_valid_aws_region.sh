#!/bin/bash
is_valid_aws_region() {
    local region_name=$1
    
    # Check if region name is provided
    if [ -z "$region_name" ]; then
        echo "Error: Region name must be provided." >&2
        return 1
    fi
    
    # Fetch the list of valid AWS regions
    local aws_regions=$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text 2>/dev/null)
    
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
