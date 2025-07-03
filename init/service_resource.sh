#!/bin/bash -e

if [ -n "$RESOURCE_NAME" ]; then 

prompt_service="
The current $SERVICE_NAME resource name is $RESOURCE_NAME. Enter a new service name to change it. (Type help for a list of services):
"

else

prompt_service="
Enter the $SERVICE_NAME resource name that you want to deploy (type help for a list of resources):
"

fi

while [ -z "$RESOURCE_NAME" ]; do
    read -p "$prompt_service" CHANGE_RESOURCE_NAME
    if [ "$CHANGE_RESOURCE_NAME" == "help" ]; then
      list_service_resource_names $SERVICE_NAME $ENV_PROFILE $REGION
      CHANGE_RESOURCE_NAME=""
    fi
    #use existing service
    if [ -n "$RESOURCE_NAME" ] && [ -z "$CHANGE_RESOURCE_NAME" ]; then break; fi
    #use new service name
    if [ -n "$CHANGE_RESOURCE_NAME" ]; then 
        RESOURCE_NAME="$CHANGE_RESOURCE_NAME";  
       is_valid_service_resource $SERVICE_NAME $RESOURCE_NAME $ENV_PROFILE $REGION
    fi
done
