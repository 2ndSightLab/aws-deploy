#!/bin/bash -e

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

if [ $DEBUG ]; then 
  echo "ENV_FILE_PATH: $ENV_FILE_PATH"

  echo "Configure git repository"
fi

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
  while true; do
    read -p "$prompt_git_url" g
    if [ "$g" != "help" ]; then
        break
    fi
    echo "$help"
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

if [ $DEBUG ]; then
  echo "GIT_REPO_PARENT_DIR: $GIT_REPO_PARENT_DIR"
fi
if [ -z "$GIT_REPO_PARENT_DIR" ]; then echo "Error: GIT_REPO_PARENT_DIR is not set in environment file."; ecxit 1; fi

GIT_REPO_DIR="$GIT_REPO_PARENT_DIR/$GIT_REPO_NAME"
if [ $DEBUG ]; then
  echo "GIT_REPO_DIR: $GIT_REPO_DIR"
fi 

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
