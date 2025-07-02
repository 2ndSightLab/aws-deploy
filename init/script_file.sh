#!/bin/bash -e
echo "Generating script file path"
SCRIPT_FILE_PATH=$(get_script_file_path $SERVICE_NAME $RESOURCE_NAME $ACCOUNT $REGION $GIT_REPO_DIR)
echo "SCRIPT_FILE_PATH: $SCRIPT_FILE_PATH"
echo "Creating deploy script for resource: $RESOURCE_TYPE and tempate file: $TEMPLATE_FILE_PATH in region: $REGION"
create_deploy_script_for_resource "$RESOURCE_TYPE" "$SCRIPT_FILE_PATH" "$TEMPLATE_FILE_PATH" "$ENV_PROFILE" "$REGION" $SCHEMA_B64
if [ ! -f $SCRIPT_FILE_PATH ]; then echo "$SCRIPT_FILE_PATH does not exist. Exiting."; exit; fi
