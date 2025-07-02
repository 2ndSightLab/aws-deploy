#!/bin/bash -e

echo "Initializing..."

#source all the files in the functions directory
for file in functions/*; do [ -f "$file" ] && source "$file"; done

ENV_NAME=""
ENV_DIR="$HOME/.aws-deploy"
ENV_FILE_PATH=""
GIT_REPO_URL=""
GIT_REPO_PARENT_DIR=""
GIT_REPO_DIR=""
GIT_REPO_NAME=""
ENV_PROFILE=""


if [ ! -d "$ENV_DIR" ]; then mkdir "$ENV_DIR"; fi

#set environment
help="
~~~
The environment name used to create a file that stores configuration information. 
This approach allows you to create configurations for different environments such as Dev, QA, Prod 
or even more granular environments such as for teams, projects, or applications. 
The configuration file includes things like which AWS profile(s) to use to deploy resources 
for that environment and the github repository to use to store the output files. 
The environment name is also used in CloudFormation stack names and resource names.
~~~
"

prompt_environment="
Enter environment name. (To learn more about environments, enter help):
"

while [ -z "$e" ]; do

    read -p "$prompt_environment" e    
    if [ "$e" == "help" ]; then echo $help; e=""; fi
done
    
ENV_NAME="$e"
ENV_FILE_PATH="$ENV_DIR/$ENV_NAME"   
if [ ! -f "$env_file_path" ]; then touch $ENV_FILE_PATH; fi    

echo "ENV_FILE_PATH: $ENV_FILE_PATH"

echo "Configure git repository"
help="
~~~
The github repository URL is used to clone the git repo where the output files will be stored that are generated
by aws-deploy. You will be asked for a directory where the repository should be cloned. 
Each stack will have it's own directory /account/region/stackname/.
The deploy script, cloudformation template, and parameters will be stored to the directory.
~~~
"
     
prompt_git_url="
Enter the git repository URL where configuration files are stored.
Enter if you don't want to save the output. 
(To learn how the repository is used, enter help):
"

GIT_REPO_URL=$(get_env_param_value "$ENV_FILE_PATH" "GIT_REPO_URL")

clone="n"
if [ -z $GIT_REPO_URL ]; then
  clone="y"
  while [ -z "$g" ]; do
    read -p "$prompt_git_url" g
    if [ "$g" == "help" ]; then echo $help; g=""; fi
  done

  GIT_REPO_URL="$g"
  set_env_param_value "$ENV_FILE_PATH" "GIT_REPO_URL" "$GIT_REPO_URL"
  GIT_REPO_URL=$(get_env_param_value "$ENV_FILE_PATH" "GIT_REPO_URL")
  echo "GIT_REPO_URL: $GIT_REPO_URL"
  if [ -z "$GIT_REPO_URL" ]; then echo "GIT_REPO_URL not set"; exit 1; fi
  
fi

GIT_REPO_NAME=$(basename "$GIT_REPO_URL" .git)
echo "GIT_REPO_NAME: $GIT_REPO_NAME"
if [ -z "$GIT_REPO_NAME" ]; then echo "GIT_REPO_NAME not set"; exit 1; fi

prompt_git_parent_dir="
Enter the parent directory where you want to clone $GIT_REPO_URL. 
Enter for default which clones the repo contents to $HOME/$GIT_REPO_NAME.
"

GIT_REPO_PARENT_DIR=$(get_env_param_value "$ENV_FILE_PATH" "GIT_REPO_PARENT_DIR")
if [ -z "$GIT_REPO_PARENT_DIR" ]; then
  clone="y"
  read -p "$prompt_git_parent_dir" GIT_REPO_PARENT_DIR
  if [ -z "$GIT_REPO_PARENT_DIR" ]; then GIT_REPO_PARENT_DIR="$HOME"; fi
  set_env_param_value "$ENV_FILE_PATH" "GIT_REPO_PARENT_DIR" "$GIT_REPO_PARENT_DIR"

  GIT_REPO_PARENT_DIR=$(get_env_param_value "$ENV_FILE_PATH" "GIT_REPO_PARENT_DIR")
fi

echo "GIT_REPO_PARENT_DIR: $GIT_REPO_PARENT_DIR"
if [ -z "$GIT_REPO_PARENT_DIR" ]; then echo "Error: GIT_REPO_PARENT_DIR is not set in environment file."; ecxit 1; fi

GIT_REPO_DIR="$GIT_REPO_PARENT_DIR/$GIT_REPO_NAME"
echo "GIT_REPO_DIR: $GIT_REPO_DIR"

pompt_repo_overwrite="
Repo directory: $GIT_REPO_DIR already exists. Do you want to overwrite it? (y)
"
if [ ! -d $GIT_REPO_DIR ]; then #directory doe snot exist
    clone="y"
elif [ "$clone" == "y" ];  then #directory exists
    read -p "$pompt_repo_overwrite " clone
    if [ "$clone" == "y" ]; then rm -rf $GIT_REPO_DIR; fi
fi

prompt_clone="
Clone $GIT_REPO_URL into directory: $GIT_REPO_DIR?
"

if [ "$clone" == "y" ]; then
    read -p "$prompt_clone" clone
    if [ "$clone" = "y" ]; then
        mkdir -p "$GIT_REPO_PARENT_DIR"
        git clone "$GIT_REPO_URL" "$GIT_REPO_DIR"
    fi
fi 

echo "Configure AWS CLI profile"

help="
~~~
The AWS CLI profile is used with the commands that look up and deploy resources. 
To view a list of profiles run this command: 
   aws configure list-profiles
If no profiles are configured either your system is not configured with AWS credentials,
or commands are executed using a default profile for the environment (e.g. CloudShell). 
If do not enter a profile name, then the default profile will be used to run aws commands.
~~~
"
      
prompt_profile="
Enter the AWS CLI profile name you want to use. Enter for the default profile. 
(Type help for more information.)
"

ENV_PROFILE=$(get_env_param_value "$ENV_FILE_PATH" "ENV_PROFILE")

if [ -n "$ENV_PROFILE" ]; then
     is_valid_aws_profile $ENV_PROFILE
     if [ $? -ne 0 ]; then 
         echo "Invald profile: $ENV_PROFILE"
         ENV_PROFILE=""; 
    fi
fi

if [ -z "$ENV_PROFILE" ]; then

  while [ -z "$p" ]; do
    read -p "$prompt_profile" p
    if [ "$p" == "help" ]; then echo $help; p=""
    else
      if [ "$p" == "" ]; then p="default"; fi
      is_valid_aws_profile $p
      if [ $? -ne 0 ]; then 
         echo "Invald profile: $p"
         p=""; 
      fi
    fi
  done

  ENV_PROFILE=$p
  set_env_param_value "$ENV_FILE_PATH" "ENV_PROFILE" "$ENV_PROFILE"
  ENV_PROFILE=$(get_env_param_value "$ENV_FILE_PATH" "ENV_PROFILE")

fi

echo "ENV_PROFILE: $ENV_PROFILE"

#set the region
echo "get profile region"
REGION=$(get_region $ENV_PROFILE)
echo "The current region is $REGION. If you want to change the region enter it now"
read CHANGE_REGION
if [ "$CHANGE_REGION" != "" ]; then REGION=$CHANGE_REGION; fi

echo "testing profile"
aws sts get-caller-identity --profile $ENV_PROFILE --region $REGION

IDENTITY_ARN=$(get_current_identity_arn $ENV_PROFILE $REGION)
IDENTITY_NAME=$(get_identity_name_from_arn $IDENTITY_ARN $ENV_PROFILE $REGION)

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

prompt_resource="
Enter the resource of the service $SERVICE_NAME that you want to deploy (type help for a list of resources):
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

prompt_name="
If the resource is a user, for a specific user, or associated with an application enter the name. Enter if n/a:
"
read -p "$prompt_name" NAME

echo "Initializing...please wait..."
STACK_NAME=$(get_stack_name "$ENV_NAME" "$IDENTITY_NAME" "$SERVICE_NAME" "$RESOURCE_NAME" "$NAME")
STACK_RESOURCE_NAME=$(get_stack_resource_name "$ENV_NAME" "$SERVICE_NAME" "$RESOURCE_NAME" "$REGION" "$NAME")

ACCOUNT=$(get_aws_account $PROFILE)
if [ -z "$ACCOUNT" ]; then echo "Error: Account not set from profile $ENV_PROFILE"; exit; fi

TEMPLATE_FILE_PATH=$(get_template_file_path $SERVICE_NAME $RESOURCE_NAME $ACCOUNT $REGION $GIT_REPO_DIR)
create_cloudformation_template $SERVICE_NAME $RESOURCE_NAME $TEMPLATE_FILE_PATH $ENV_PROFILE $REGION
if [ ! -f $TEMPLATE_FILE_PATH ]; then echo "$TEMPLATE_FILE_PATH does not exist. Exiting."; exit; fi

SCRIPT_FILE_PATH=$(get_script_file_path $SERVICE_NAME $RESOURCE_NAME)
create_deploy_script_for_resource $SERVICE_NAME $RESOURCE_NAME $ENV_PROFILE $REGION
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
echo "AWS CLI PROFILE: $ENV_PROFILE"
echo ""

#the deploy script assumes the above values have been set prior to sourcing it
echo "Enter to deploy the resource. Control-C to exit."
read ok

echo "Execute the deploy script $SCRIPT_FILE_PATH"

# this script depends on some of the variables set above
source $SCRIPT_FILE_PATH
