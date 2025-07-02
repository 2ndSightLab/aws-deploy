#!/bin/bash -e
get_stack_file_path(){

    validate_first_n_args_set 4  "$@"
    
    local SERVICE_NAME="$1"
    local RESOURCE_NAME="$2"
    local STACK_NAME="$3"
    local ACCOUNT="$4"
    local REGION="$5"
    local GIT_REPO_DIR="$6" 

    local DIR_PATH="$ACCOUNT/$REGION/stacks/"
    
    if [ -n "$GIT_REPO_DIR" ]; then 
        DIR_PATH="$GIT_REPO_DIR/$DIR_PATH"
    fi
    
    # Create the directory structure if it doesn't exist
    if [ ! -d "$DIR_PATH" ]; then
        mkdir -p "$DIR_PATH"
    fi

    echo "$DIR_PATH/$STACK_NAME.cfg"
    
}
