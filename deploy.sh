#!/bin/bash -e

ENV_NAME=""

while [ "$ENV_NAME" == "" ]; do
    echo "Enter environment name. (To learn more about environment names, enter help:"
    read e
    if [ "e" == "help" ]; then
        echo "The environment name used to create a file that stores configuration information. \
              This approach allows you to create configurations for different environments such as Dev, QA, Prod \
              or even more granular environments such as for projects, teams, or applications. \
              The configuration file includes things like which AWS profile to use to deploy resources \
              for that environment and the github repository to use to store the output files. \
              The environment name is also used in CloudFormation stack names and resource names."
    else
        ENV_NAME="$e"
    fi
done

read ok


# check to see if the profile config file exists. If not create it.


echo "source all the files in the functions directory"
for file in functions/*; do [ -f "$file" ] && source "$file"; done

REGION=$(get_region)
IDENTITY_ARN=$(get_current_identity_arn)
IDENTITY_NAME=$(get_identity_name_from_arn $IDENTITY_ARN)

SERVICE_NAME=""
while [ -z "$SERVICE_NAME" ]; do
    echo "Enter the service from which you want to deploy a resource (type help for a list of services):"
    read SERVICE_NAME
    if [ "$SERVICE_NAME" == "help" ]; then
      list_service_names
      SERVICE_NAME=""
    fi
done

is_valid_aws_service $SERVICE_NAME

RESOURCE_NAME=""
while [ -z "$RESOURCE_NAME" ]; do
    echo "Enter the resource of the service $SERVICE_NAME that you want to deploy (type help for a list of resources):"
    read RESOURCE_NAME
    if [ "$RESOURCE_NAME" == "help" ]; then
       list_service_resource_names $SERVICE_NAME
       RESOURCE_NAME=""
    fi
done

is_valid_service_resource $SERVICE_NAME $RESOURCE_NAME

NAME=""
echo "Is this resource a user, for a specific user, or associated with an application? [y]"
read hasname
if [ "$hasname" == "y" ]; then 
  echo "Enter the name: "
  read NAME
fi

echo "Initializing...please wait..."
STACK_NAME=$(get_stack_name "$ENV_NAME" "$IDENTITY_NAME" "$SERVICE_NAME" "$RESOURCE_NAME" "$NAME")
STACK_RESOURCE_NAME=$(get_stack_resource_name "$ENV_NAME" "$SERVICE_NAME" "$RESOURCE_NAME" "$NAME")

TEMPLATE_FILE_PATH=$(get_template_file_path $SERVICE_NAME $RESOURCE_NAME)
create_cloudformation_template $SERVICE_NAME $RESOURCE_NAME
if [ ! -f $TEMPLATE_FILE_PATH ]; then echo "$TEMPLATE_FILE_PATH does not exist. Exiting."; exit; fi

SCRIPT_FILE_PATH=$(get_script_file_path $SERVICE_NAME $RESOURCE_NAME)
create_deploy_script_for_resource $SERVICE_NAME $RESOURCE_NAME
if [ ! -f $SCRIPT_FILE_PATH ]; then echo "$SCRIPT_FILE_PATH does not exist. Exiting."; exit; fi

echo ""
echo "ENV: $ENV_NAME"
echo "IDENTITY_ARN: $IDENTITY_ARN"
echo "IDENTITY_NAME: $IDENTITY_NAME"
echo "REGION: $REGION"
echo "STACK_NAME: $STACK_NAME"
echo "STACK_RESOURCE_NAME: $STACK_RESOURCE_NAME"
echo "TEMPLATE FILE: $TEMPLATE_FILE_PATH"
echo "SCRIPT: $SCRIPT_FILE_PATH"
echo ""

echo "Do you want to deploy the resource now (y)?"
read ok
if [ "$ok" == "y" ]; then
    echo "Execute the deploy script $SCRIPT_FILE_PATH"
    source $SCRIPT_FILE_PATH
fi
