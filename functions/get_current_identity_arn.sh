#!/bin/bash -e
get_current_identity_arn() {
    local ENV_PROFILE="$1"
    local REGION="$2"
    
    if [ -z "$ENV_PROFILE" ]; then echo "$ENV_PROFILE not set in deploy_cloudformation_stack" >&2; exit 1; fi
    if [ -z "$REGION" ]; then echo "$REGION not set in deploy_cloudformation_stack" >&2; exit 1; fi
    
    local arn
    arn=$(aws sts get-caller-identity --query 'Arn' --profile $ENV_PROFILE --region $REGION --output text)
    if [ $? -ne 0 ]; then
        echo "Error: Failed to retrieve identity ARN. Check your AWS credentials and permissions." >&2
        exit 1
    fi
    
    echo "$arn"
}
