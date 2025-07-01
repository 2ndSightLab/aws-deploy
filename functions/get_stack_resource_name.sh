#!/bin/bash -e
get_stack_resource_name() {
    local ENV_NAME="$1" 
    local SERVICE="$2" 
    local RESOURCE="$3"
    local NAME="$4"
    local REGION="$5"
    
    if [ -z "$REGION" ]; then echo "$REGION not set in deploy_cloudformation_stack" >&2; exit 1; fi
  
    # Check if all parameters are provided
    if [ -z "$ENV_NAME" ] || [ -z "$SERVICE" ] || [ -z "$RESOURCE" ] ; then
        echo "Error: All parameters (ENV_NAME, SERVICE, RESOURCE) must be provided." >&2
        exit
    fi

    # Return the concatenated string
    resource_name="$ENV_NAME-$SERVICE-$RESOURCE"

    if [ "$NAME" != "" ]; then
        resource_name="$resource_name-$NAME"
    fi

    #adding region so it is clear which region the command was executed in to create this resource (for global resources)
    #and to create a unique name per region if neccessary
    resource_name=$resource_name-$REGION
    
    echo $resource_name | tr '[:upper:]' '[:lower:]'
}
