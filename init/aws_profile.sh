#!/bin/bash -e

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

if [ DEBUG ]; then echo "ENV_PROFILE: $ENV_PROFILE"; fi
