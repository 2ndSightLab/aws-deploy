#!/bin/bash -e
TEMPLATE_FILE_PATH=$(get_template_file_path $SERVICE_NAME $RESOURCE_NAME $ACCOUNT $REGION $GIT_REPO_DIR)
create_cloudformation_template $SERVICE_NAME $RESOURCE_NAME $TEMPLATE_FILE_PATH $ENV_PROFILE $REGION
if [ ! -f $TEMPLATE_FILE_PATH ]; then echo "$TEMPLATE_FILE_PATH does not exist. Exiting."; exit; fi
