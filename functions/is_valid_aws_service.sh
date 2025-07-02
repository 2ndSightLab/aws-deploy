#!/bin/bash -e

is_valid_aws_service() {

    validate_fist_n_args_set 3

    local service_name="$1"
    local ENV_PROFILE=$2
    local REGION=$3

    # Check if service name is provided
    if [ -z "$service_name" ]; then
        echo "Error: Service name must be provided." >&2
        exit
    fi
    
    if aws cloudformation list-types --visibility PUBLIC --type RESOURCE --filters TypeNamePrefix=AWS::${SERVICE_NAME}:: --query 'length(TypeSummaries)' --profile $ENV_PROFILE --region $REGION --output text | grep -q -v ^0$; then
        echo "${SERVICE_NAME} service exists"
    else
        echo "${SERVICE_NAME} service does not exist"
        echo "Service names are CASE SENSITIVE and need to match proper CloudFormation upper and lower case."
        exit
    fi
}
