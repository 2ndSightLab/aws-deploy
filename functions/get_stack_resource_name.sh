#!/bin/bash -e
get_stack_resource_name() {

    validate_fist_n_args_set 5
    
    local ENV_NAME="$1" 
    local SERVICE="$2" 
    local RESOURCE="$3"
    local NAME="$4"
    local REGION="$5"

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
