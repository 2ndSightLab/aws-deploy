#!/bin/bash -e


if [ -n "$SERVICE_NAME" ]; then 

prompt_service="
The current service name is $SERVICE_NAME. Enter a new service name to change it. (type help for a list of services):
"

else

prompt_service="
Enter the service from which you want to deploy a resource (type help for a list of services):
"

fi

while [ -z "$SERVICE_NAME" ]; do
    read -p "$prompt_service" CHANGE_SERVICE_NAME
    
    if [ "$CHANGE_SERVICE_NAME" == "help" ]; then
      list_service_names $ENV_PROFILE $REGION
      CHANGE_SERVICE_NAME=""
    fi
    #use existing service
    if [ -n "$SERVICE_NAME" ] && [ -z "$CHANGE_SERVICE_NAME" ]; then break; fi
    #use new service name
    if [ -n "$CHANGE_SERVICE_NAME" ]; then 
        SERVICE_NAME="$CHANGE_SERVICE_NAME"; 
        is_valid_aws_service $SERVICE_NAME $ENV_PROFILE $REGION
    fi
done


