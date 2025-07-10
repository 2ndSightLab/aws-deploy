#!/bin/bash -e
get_stack_resource_name() {

    validate_first_n_args_set 4  "$@"
    
    local ENV_NAME="$1" 
    local SERVICE="$2" 
    local RESOURCE="$3"
    local REGION="$4"
    local NAME="$5" #optional
    
    echo "generating stack resource name"
    
    resource_name="$ENV_NAME-$SERVICE-$RESOURCE"

    if [ "$NAME" != "" ]; then
        resource_name="$resource_name-$NAME"
    fi

    resource_name=$resource_name-$REGION
    
    echo $resource_name | tr '[:upper:]' '[:lower:]'
}
