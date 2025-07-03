#!/bin/bash -e
echo "Generating script file path"
SCRIPT_FILE_PATH=$(get_script_file_path "$SERVICE_NAME" "$RESOURCE_NAME" "$ACCOUNT" "$REGION" "$GIT_REPO_DIR")
if [ -z "$SCRIPT_FILE_PATH" ]; then echo "Error: Script file path not set"; exit; fi
echo "SCRIPT_FILE_PATH: $SCRIPT_FILE_PATH"
create_deploy_script_for_resource "$ENV_PROFILE" "$REGION" "$RESOURCE_TYPE" "$SCRIPT_FILE_PATH" "$TEMPLATE_FILE_PATH" "$SCHEMA_B64" "$STACK_NAME" "$STACK_FILE_PATH"
if [ ! -f $SCRIPT_FILE_PATH ]; then echo "$SCRIPT_FILE_PATH does not exist. Exiting."; exit; fi
