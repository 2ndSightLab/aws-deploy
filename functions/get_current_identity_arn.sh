#!/bin/bash -e
get_current_identity_arn() {
    local arn
    arn=$(aws sts get-caller-identity --query 'Arn' --output text)
    if [ $? -ne 0 ]; then
        echo "Error: Failed to retrieve identity ARN. Check your AWS credentials and permissions." >&2
        exit 1
    fi
    
    echo "$arn"
}
