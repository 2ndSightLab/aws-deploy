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

prompt="
Enter environment name. (To learn more about environments, enter help):
"

while [ -z $e ]; do
    read -p "$prompt" e    
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

GIT_REPO_URL=$(get_env_param_value "$ENV_FILE_PATH" "GIT_REPO")

if [ -z $GIT_REPO_URL ]; then
  echo "error: git url not found."
  cat $GIT_REPO_URL
  exit
fi

clone="n"
if [ -z $GIT_REPO_URL ]; then
  clone="y"
  while [ -z $g ]; do
    read -p "$prompt_git_url" g
    if [ "$g" == "help" ]; then echo $help; g=""; fi
  done

  GIT_REPO_URL="$g"
  set_env_param_value "$ENV_FILE_PATH" "GIT_REPO_URL" "$GIT_REPO_URL"
  GIT_REPO_URL=$(get_env_param_value "$ENV_FILE_PATH" "GIT_REPO_URL")
  echo "GIT_REPO_URL: $GIT_REPO_URL"
  if [ -z $GIT_REPO_URL ]; then echo "GIT_REPO_URL not set"; exit 1; fi
  
fi

GIT_REPO_NAME=$(basename $GIT_REPO_URL | sed "s/[[:space:]\'\"]//g" | sed 's|\.git$||')
echo "GIT_REPO_NAME: $GIT_REPO_NAME"
if [ -z $GIT_REPO_NAME ]; then echo "GIT_REPO_NAME not set"; exit 1; fi

prompt_git_parent_dir="
Enter the parent directory where you want to clone $GIT_REPO_URL. 
Enter for default which clones the repo contents to $HOME/$GIT_REPO_NAME.
"

if [ "$clone" == "y" ]; then
  #set git repo parent dir parameter
  while [ -z "$GIT_REPO_PARENT_DIR" ]; do
    read -p "$prompt_git_parent_dir" GIT_REPO_PARENT_DIR
    if [ -z $GIT_REPO_PARENT_DIR ]; then GIT_REPO_PARENT_DIR="$HOME"; fi
    echo "GIT_REPO_PARENT_DIR: $GIT_REPO_PARENT_DIR"
  done
fi

GIT_REPO_DIR="$GIT_REPO_PARENT_DIR/$GIT_REPO_NAME"

pompt_repo_overwrite="
$GIT_REPO_DIR already exists. Do you want to overwrite it? (y)
"

if [ "$clone" == "y" ] && [ -d $GIT_REPO_DIR ]; then
    read -p "$pompt_repo_overwrite " clone
    if [ "$clone" == "y" ]; then rm -rf $GIT_REPO_DIR; fi
fi

info="
Cloning $REPO_URL into directory: $GIT_REPO_PARENT_DIR. 
Repo directory: $GIT_REPO_DIR"
"
echo $info

if [ "$clone" == "y" ]; then
    mkdir -p $GIT_REPO_PARENT_DIR
    git clone $REPO_URL $GIT_REPO_PARENT_DIR
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
      
prompt="
Enter the AWS CLI profile name you want to use to deploy resources or enter for the default profile. 
(Type help for more information.)
"
ENV_PROFILE=$(get_env_param_value "$ENV_FILE_PATH" "ENV_PROFILE")
if [ -z "$ENV_PROFILE" ]; then

  while [ -z $p ]; do
    read -p "$prompt_git_url" p
    if [ "$p" == "help" ]; then echo $help; p=""; fi
  done
  
  ENV_PROFILE=$p
  set_env_param_value "$ENV_FILE_PATH" "ENV_PROFILE" "$ENV_PROFILE"
  ENV_PROFILE=$(get_env_param_value "$ENV_FILE_PATH" "ENV_PROFILE")

else
  echo "ENV_PROFILE is set in $ENV_FILE_PATH"
fi

echo "Enviroment $ENV_NAME configuration:"
cat $ENV_FILE_PATH
msg="
If you want to change the configuration for evironment $ENV_NAME
then modify the file $ENV_FILE_PATH or delete it to reconfigure it.
Enter to continue. Ctrl-c to exit.
"
echo $msg
read ok

#set the region
REGION=$(get_region)
echo "The current region is $REGION. If you want to change the region enter it now"
read CHANGE_REGION
if [ "$CHANGE_REGION" != "" ]; then REGION=$CHANGE_REGION; fi

# get the identity running the commands
IDENTITY_ARN=$(get_current_identity_arn $ENV_RROFILE)
IDENTITY_NAME=$(get_identity_name_from_arn $IDENTITY_ARN $ENV_PROFILE)

prompt = "
Enter the service from which you want to deploy a resource (type help for a list of services):
"
SERVICE_NAME=""
while [ -z "$SERVICE_NAME" ]; do
    read SERVICE_NAME
    if [ "$SERVICE_NAME" == "help" ]; then
      list_service_names $ENV_PROFILE
      SERVICE_NAME=""
    fi
done

is_valid_aws_service $SERVICE_NAME $ENV_PROFILE

prompt "
Enter the resource of the service $SERVICE_NAME that you want to deploy (type help for a list of resources):
"
RESOURCE_NAME=""
while [ -z "$RESOURCE_NAME" ]; do
    read -p "$prompt" RESOURCE_NAME
    if [ "$RESOURCE_NAME" == "help" ]; then
       list_service_resource_names $SERVICE_NAME $ENV_PROFILE
       RESOURCE_NAME=""
    fi
done

is_valid_service_resource $SERVICE_NAME $RESOURCE_NAME $ENV_PROFILE

prompt = "
If the resource is a user, for a specific user, or associated with an application enter the name. Enter if n/a:"
"
read NAME

echo "Initializing...please wait..."
STACK_NAME=$(get_stack_name "$ENV_NAME" "$IDENTITY_NAME" "$SERVICE_NAME" "$RESOURCE_NAME" "$NAME")
STACK_RESOURCE_NAME=$(get_stack_resource_name "$ENV_NAME" "$SERVICE_NAME" "$RESOURCE_NAME" "$NAME" "$REGION")

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
echo "AWS CLI PROFILE: $ENV_PROFILE"
echo ""

#the deploy script assumes the above values have been set prior to sourcing it
echo "Enter to depoy the resource. Control-C to exit."
read ok

echo "Execute the deploy script $SCRIPT_FILE_PATH"
source $SCRIPT_FILE_PATH
