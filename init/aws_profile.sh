#!/bin/bash -e

if [ $DEBUG ]; then echo "Configure AWS CLI profile"; fi

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
if [ $DEBUG ]; then  echo "Checking for profile in environment file."; fi
ENV_PROFILE=$(get_env_param_value "$ENV_FILE_PATH" "ENV_PROFILE")

if [ -z "$ENV_PROFILE" ]; then 

  if [ $DEBUG ]; then echo "Profile not set in environment file so prompt for one.";  fi

  p=""
  while [ "$p" != "help" ]; do
      read -p "$prompt_profile" p
      if [ "$p" == "help" ]; then echo $help; p=""
      else
        if [ -z "$p" ]; then p="default"; fi
        break
      fi
  done
  
  ENV_PROFILE=$p

  #if we are in the CloudShell environment make sure the default profile is configured
  if [ -n "$AWS_EXECUTION_ENV" ];  then
     if [ $DEBUG ]; then echo "AWS CloudShell environment"; fi  
        
     REGION=$(echo $AWS_REGION)
     aws configure set region $REGION
     aws configure set output json
     aws configure set credential_source EcsContainer   
   fi

fi

if [ $DEBUG ]; then echo "ENV_PROFILE: $ENV_PROFILE"; fi  
is_valid_aws_profile "$ENV_PROFILE"
if [ $? -ne 0 ]; then echo "Invald profile: $p"; exit; p=""; fi

if [ $DEBUG ]; then echo "$p is a valid profile."; fi
if [ $DEBUG ]; then echo "Set environment profile in environment file."; fi
set_env_param_value "$ENV_FILE_PATH" "ENV_PROFILE" "$ENV_PROFILE"
ENV_PROFILE=$(get_env_param_value "$ENV_FILE_PATH" "ENV_PROFILE")
if [ $DEBUG ]; then echo "ENV_PROFILE from environment config file: $ENV_PROFILE"; fi
if [ -z $ENV_PROFILE ]; then echo "ENV_PROFILE not set. Exiting"; exit; fi
