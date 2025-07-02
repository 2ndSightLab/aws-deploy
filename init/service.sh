#!/bin/bash -e

prompt_service="
Enter the service from which you want to deploy a resource (type help for a list of services):
"
SERVICE_NAME=""
while [ -z "$SERVICE_NAME" ]; do
    read -p "$prompt_service" SERVICE_NAME
    if [ "$SERVICE_NAME" == "help" ]; then
      list_service_names $ENV_PROFILE $REGION
      SERVICE_NAME=""
    fi
done

is_valid_aws_service $SERVICE_NAME $ENV_PROFILE $REGION
