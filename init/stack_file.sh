#!/bin/bash -e

echo "Generate stack file name"
STACK_FILE_PATH=$(get_stack_file_path \
    $SERVICE_NAME \
    $RESOURCE_NAME \
    $STACK_NAME \
    $ACCOUNT \
    $REGION \
    $GIT_REPO_DIR)

if [ -z "$STACK_FILE_PATH" ]; then echo "Error: STACK_FILE_NAME not set"; exit; fi

echo "STACK_FILE_NAME: $STACK_FILE_PATH"
