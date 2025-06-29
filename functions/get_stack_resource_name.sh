#!/bin/bash -e
get_stack_resource_name() {
    local ENV_NAME="$1" 
    local SERVICE="$2" 
    local RESOURCE="$3"
    local NAME="$4"

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

    echo $resource_name | tr '[:upper:]' '[:lower:]'
}
