#!/bin/bash -e
SCRIPT_FILE_PATH=$(get_script_file_path $SERVICE_NAME $RESOURCE_NAME)
create_deploy_script_for_resource $SERVICE_NAME $RESOURCE_NAME $ENV_PROFILE $REGION
if [ ! -f $SCRIPT_FILE_PATH ]; then echo "$SCRIPT_FILE_PATH does not exist. Exiting."; exit; fi
