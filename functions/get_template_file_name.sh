#!/bin/bash -e
get_template_file_path(){
    local SERVICE_NAME="$1"
    local RESOURCE_NAME="$2" 

    local DIR_PATH="resources/$SERVICE_NAME"
    
    # Create the directory structure if it doesn't exist
    if [ ! -d "$DIR_PATH" ]; then
        mkdir -p "$DIR_PATH"
    fi
    
    echo "$DIR_PATH/$RESOURCE_NAME.yaml"
    
}
