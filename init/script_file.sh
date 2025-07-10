#!/bin/bash -e
create_deploy_script_for_resource "$ENV_PROFILE" "$REGION" "$RESOURCE_TYPE" "$SCRIPT_FILE_PATH" "$TEMPLATE_FILE_PATH" "$SCHEMA_B64" "$STACK_NAME" "$STACK_FILE_PATH"
if [ ! -f $SCRIPT_FILE_PATH ]; then echo "$SCRIPT_FILE_PATH does not exist. Exiting."; exit; fi
