#!/bin/bash -e
echo "generate template file path"
TEMPLATE_FILE_PATH=$(get_template_file_path $SERVICE_NAME $RESOURCE_NAME $ACCOUNT $REGION $GIT_REPO_DIR)
if [ -z $TEMPLATE_FILE_PATH ]; then echo "$TEMPLATE_FILE_PATH is empty. Exiting."; exit; fi
echo "TEMPLATE_FILE_PATH: $TEMPLATE_FILE_PATH"

echo "Creating template"
create_cloudformation_template $RESOURCE_NAME $RESOURCE_TYPE $TEMPLATE_FILE_PATH $ENV_PROFILE $REGION $SCHEMA_B64
if [ ! -f $TEMPLATE_FILE_PATH ]; then echo "$TEMPLATE_FILE_PATH does not exist. Exiting."; exit; fi
