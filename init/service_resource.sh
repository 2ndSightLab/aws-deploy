#!/bin/bash -e

prompt_resource="
Enter the resource of the service $RESOURCE_NAME that you want to deploy (type help for a list of resources):
"
RESOURCE_NAME=""
while [ -z "$RESOURCE_NAME" ]; do
    read -p "$prompt_resource" RESOURCE_NAME
    if [ "$RESOURCE_NAME" == "help" ]; then
       list_service_resource_names $SERVICE_NAME $ENV_PROFILE $REGION
       RESOURCE_NAME=""
    fi
done

is_valid_service_resource $SERVICE_NAME $RESOURCE_NAME $ENV_PROFILE $REGION
