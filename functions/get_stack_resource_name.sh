#!/bin/bash -e
get_stack_resource_name() {

    validate_first_n_args_set 4  "$@"
    
    local ENV_NAME="$1" 
    local SERVICE="$2" 
    local RESOURCE="$3"
    local REGION="$4"
    local NAME="$5" #optional
    

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
