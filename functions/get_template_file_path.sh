#!/bin/bash -e
get_template_file_path(){

    validate_first_n_args_set 2  "$@"
    
    local SERVICE_NAME="$1"
    local RESOURCE_NAME="$2"
    local GIT_REPO_DIR="$3" 

    local DIR_PATH="resources/$SERVICE_NAME"
    
    # Create the directory structure if it doesn't exist
    if [ ! -d "$DIR_PATH" ]; then
        mkdir -p "$DIR_PATH"
    fi

    path="$DIR_PATH/$RESOURCE_NAME.yaml"
    if [ -z "$GIT_REPO_DIR" ]; then 
      path="$GIT_REPO_DIR/$path"
    fi
    
}
