#!/bin/bash.sh -e

if [ $DEBUG ]; then echo "generating file paths"; fi

BASE_FILE_PATH="$ACCOUNT/$REGION/$SERVICE_NAME/$RESOURCE_NAME"
    
if [ -n "$GIT_REPO_DIR" ]; then 
    BASE_FILE_PATH="$GIT_REPO_DIR/$BASE_FILE_PATH"
fi

RESOURCE_PATH="$BASE_FILE_PATH/resources"

# Create the directory structure if it doesn't exist
if [ ! -d "$RESOURCE_PATH" ]; then
    mkdir -p "$RESOURCE_PATH"
fi

STACKS_PATH="$BASE_FILE_PATH/stacks"

if [ ! -d "$STACKS_PATH" ]; then
    mkdir -p "$STACKS_PATH"
fi

TEMPLATE_FILE_PATH="$RESOURCE_PATH/$RESOURCE_NAME.yaml"
SCRIPT_FILE_PATH="$RESOURCE_PATH/$RESOURCE_NAME.sh"
STACK_FILE_PATH="$STACKS_PATH/$STACK_NAME.cfg"

if [ $DEBUG ]; then 
    echo "TEMPLATE_FILE_PATH: $TEMPLATE_FILE_PATH"
    echo "SCRIPT_FILE_PATH: $SCRIPT_FILE_PATH"
    echo "STACK_FILE_PATH: $STACK_FILE_PATH"
fi
