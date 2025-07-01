#!/bin/bash -e
get_script_file_path(){
    local SERVICE_NAME="$1"
    local RESOURCE_NAME="$2" 

    if [ -z "$SERVICE_NAME" ]; then echo "$SERVICE_NAME not set in get_script_file_path" >&2; exit 1; fi
    if [ -z "$RESOURCE_NAME" ]; then echo "$RESOURCE_NAME not set in get_script_file_path" >&2; exit 1; fi
    
    local DIR_PATH="resources/$SERVICE_NAME"
    
    # Create the directory structure if it doesn't exist
    if [ ! -d "$DIR_PATH" ]; then
        mkdir -p "$DIR_PATH"
    fi
  
    echo "$DIR_PATH/$RESOURCE_NAME.sh"
}
