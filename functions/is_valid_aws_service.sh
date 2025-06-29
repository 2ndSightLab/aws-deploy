#!/bin/bash -e

is_valid_aws_service() {
    local service_name="$1"
    
    # Check if service name is provided
    if [ -z "$service_name" ]; then
        echo "Error: Service name must be provided." >&2
        exit
    fi
    
    if aws cloudformation list-types --visibility PUBLIC --type RESOURCE --filters TypeNamePrefix=AWS::${SERVICE_NAME}:: --query 'length(TypeSummaries)' --output text | grep -q -v ^0$; then
        echo "${SERVICE_NAME} service exists"
    else
        echo "${SERVICE_NAME} service does not exist"
        echo "Service names are CASE SENSITIVE and need to match proper CloudFormation upper and lower case."
        exit
    fi
}
