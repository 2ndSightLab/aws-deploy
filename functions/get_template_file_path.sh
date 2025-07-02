#!/bin/bash -e
get_template_file_path(){

    validate_first_n_args_set 4  "$@"
    
    local SERVICE_NAME="$1"
    local RESOURCE_NAME="$2"
    local ACCOUNT="$3"
    local REGION="$4"
    local GIT_REPO_DIR="$5" 

    local DIR_PATH="resources/$SERVICE_NAME"
    
    if [ -n "$GIT_REPO_DIR" ]; then 
        DIR_PATH="$GIT_REPO_DIR/$DIR_PATH"
    fi
    
    # Create the directory structure if it doesn't exist
    if [ ! -d "$DIR_PATH" ]; then
        mkdir -p "$DIR_PATH"
    fi

    echo "$DIR_PATH/$RESOURCE_NAME.yaml"
    
}
