#!/bin/bash -e
get_stack_resource_name() {
    local ENV_NAME="$1" 
    local SERVICE="$2" 
    local RESOURCE="$3"
    local NAME="$4"
    local REGION="$5"

    if [ -z "$ENV_NAME" ]; then echo "$ENV_NAME not set in get_stack_resource_name" >&2; exit 1; fi
    if [ -z "$SERVICE" ]; then echo "$SERVICE not set in get_stack_resource_name" >&2; exit 1; fi
    if [ -z "$RESOURCE" ]; then echo "$RESOURCE not set in get_stack_resource_name" >&2; exit 1; fi
    if [ -z "$NAME" ]; then echo "$NAME not set in get_stack_resource_name" >&2; exit 1; fi
    if [ -z "$REGION" ]; then echo "$REGION not set in get_stack_resource_name" >&2; exit 1; fi

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
