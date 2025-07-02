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
The environment name used to create a file that stores configuration information. 
This approach allows you to create configurations for different environments such as Dev, QA, Prod 
or even more granular environments such as for teams, projects, or applications. 
The configuration file includes things like which AWS profile(s) to use to deploy resources 
for that environment and the github repository to use to store the output files. 
The environment name is also used in CloudFormation stack names and resource names.
"

prompt="
Enter environment name. (To learn more about environments, enter help):
"
while [ "$ENV_NAME" == "" ]; do
    read -p "$prompt" e    
    if [ "$e" == "help" ]; then
      echo $help
    else
      ENV_NAME="$e"
      ENV_FILE_PATH="$ENV_DIR/$ENV_NAME"      
    fi
done

echo "ENV_FILE_PATH: $ENV_FILE_PATH"

echo "Configure git repository"
help="
The github repository URL is used to clone the git repo where the output files will be stored that are generated
by aws-deploy. You will be asked for a directory where the repository should be cloned. 
Each stack will have it's own directory /account/region/stackname/.
The deploy script, cloudformation template, and parameters will be stored to the directory.
"
      
prompt_git_url="
Enter the git repository URL where configuration files are stored.
Enter if you don't want to save the output. 
(To learn how the repository is used, enter help):
"
prompt_git_repo="
Enter the parent directory where you want to clone $GIT_REPO_URL. 
Enter for default which clones the repo contents to $HOME/$REPO_NAME.
"
pompt_repo_overwrite="
$GIT_REPO_DIR already exists. Do you want to overwrite it? (y)
"

GIT_REPO_URL=$(get_env_param_value "$ENV_FILE_PATH" "GIT_REPO")

clone="n"
if [ -z "$GIT_REPO_URL" ]; then
  clone="y"
  read -p "$prompt_git_url" g
  
  while [ "$g" == "help" ]; do
     echo $help; read -p "$prompt_git_url" g
  done

  #set git repo url env parameter
  GIT_REPO_URL="$g"
  set_env_param_value "$ENV_FILE_PATH" "GIT_REPO_URL" "$GIT_REPO_URL"
  GIT_REPO_URL=$(get_env_param_value "$ENV_FILE_PATH" "GIT_REPO_URL")

  #set git repo name env parameter
  REPO_NAME=$(basename "$url" .git)
  set_env_param_value "$ENV_FILE_PATH" "REPO_NAME" "$REPO_NAME"

  #set git repo parent dir parameter
  read -p "$prompt_git_repo " GIT_REPO_PARENT_DIR
  set_env_param_value "$ENV_FILE_PATH" "GIT_REPO_PARENT_DIR" "$GIT_REPO_PARENT_DIR"

  #set git repo dire directory parameter
  if [ -z $GIT_REPO_PARENT_DIR ]; then GIT_REPO_PARENT_DIR=$HOME; fi
     GIT_REPO_DIR="$HOME/$REPO_NAME"
  fi
  set_env_param_value "$ENV_FILE_PATH" "GIT_REPO_DIR" "$GIT_REPO_DIR"

else
  echo "GIT_REPO is set in $ENV_FILE_PATH"
fi

#if the repo directory does not exist, then clone it
if [ ! -d $GIT_REPO_DIR ]; then
  clone="y"
fi

#if clone = y and directory exists confirm overwrite
if [ "$clone" == "y" ] && [ -d $GIT_REPO_DIR ]; then
    read -p "$pompt_repo_overwrite " clone
    if [ "$clone" == "y" ]; then rm -rf $GIT_REPO_DIR; fi
  fi
fi


#after all that, if clone = y then clone the repo
msg ="
Cloning $REPO_URL into directory: $GIT_REPO_PARENT_DIR. 
Repo directory: $GIT_REPO_DIR"
"

if [ "$clone" == "y" ]; then
    echo "$msg"
    mkdir -p $GIT_REPO_PARENT_DIR
    git clone $REPO_URL $GIT_REPO_PARENT_DIR
fi 

echo "Configure AWS CLI profile"
help="
The AWS CLI profile is used with the commands that look up and deploy resources. 
To view a list of profiles run this command: 
   aws configure list-profiles
If no profiles are configured either your system is not configured with AWS credentials,
or you're using the default profile for the environment (e.g. CloudShell). 
If do not enter a profile name, then the default profile will be used to run aws commands.
"
      
prompt="
Enter the AWS CLI profile name you want to use to deploy resources or enter for the default profile. 
(Type help for more information.)
"
ENV_PROFILE=$(get_env_param_value "$ENV_FILE_PATH" "ENV_PROFILE")
if [ -z "$ENV_PROFILE" ]; then
  read -p "$prompt_message " p

  while [ "$p" == "help" ]; do
     echo $help; read -p "$prompt_message " p
  else
  
  ENV_PROFILE="$p"
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

NAME=""
prompt = "
Is this resource a user, for a specific user, or associated with an application? (y)
"
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
echo "AWS CLI PROFILE: $ENV_PROFILE"
echo ""

#the deploy script assumes the above values have been set prior to sourcing it
echo "Do you want to deploy the resource now (y)?"
read ok
if [ "$ok" == "y" ]; then
    echo "Execute the deploy script $SCRIPT_FILE_PATH"
    source $SCRIPT_FILE_PATH
fi
