#!/bin/bash

ENV_DIR="$HOME/.aws-deploy"

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
if [ ! -f "$env_file_path" ]; then 
  touch $ENV_FILE_PATH;  
  echo "$ENV_NAME:" >> "$ENV_FILE_PATH"
fi

if [ $DEBUG ]; then 
  echo "ENV_FILE_PATH: $ENV_FILE_PATH"
fi
