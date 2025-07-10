#!/bin/bash -e
if [ $DEBUG ]; then 
  echo "Creating template"
fi
create_cloudformation_template $RESOURCE_NAME $RESOURCE_TYPE $TEMPLATE_FILE_PATH $ENV_PROFILE $REGION $SCHEMA_B64
if [ ! -f $TEMPLATE_FILE_PATH ]; then echo "$TEMPLATE_FILE_PATH does not exist. Exiting."; exit; fi
