echo "Initializing..."

run(){

  #source all the files in the functions directory
  for file in functions/*; do 
    [ -f "$file" ] && source "$file"; 
    if [ $? -ne 0 ]; then
      echo "Error: failed to import $file with exit code $?"
      exit 1
    fi
  done

  local ENV_NAME=""
  local ENV_DIR=""
  local ENV_FILE_PATH=""
  local GIT_REPO_URL=""
  local GIT_REPO_PARENT_DIR=""
  local GIT_REPO_DIR=""
  local GIT_REPO_NAME=""
  local ENV_PROFILE=""
  local ACCOUNT=""
  local SERVICE_NAME=""
  local RESOURCE_NAME=""
  local RESOURCE_TYPE=""
  local SCHEMA=""
  local SCHEMA_B64=""
  
  source init/environment.sh

  source init/git_repo.sh

  source init/aws_profile.sh

  source init/identity.sh

  source init/aws_account_number.sh
    
  while [ true ]; do

    source init/region.sh

    source init/test_aws_profile.sh
    
    source init/service.sh
  
    source init/service_resource.sh
  
    source init/stack_name.sh
  
    source init/stack_resource_name.sh
  
    source init/service_resource_schema.sh
    
    source init/file_paths.sh

    source init/template_file.sh
    
    source init/script_file.sh
   
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
    echo "RESOURCE_TYPE: $RESOURCE_TYPE"
    echo "GIT_REPO_URL: $GIT_REPO_URL"
    echo "ENV_PROFILE: $ENV_PROFILE"
    echo "REGION: $REGION"
    echo "ACCOUNT: $ACCOUNT"
    echo "TEMPLATE FILE PATH: $TEMPLATE_FILE_PATH"
    echo "SCRIPT_FILE_PATH: $SCRIPT_FILE_PATH"
    echo "STACK_FILE_PATH: $STACK_FILE_PATH"
    echo ""
  
    #the deploy script assumes the above values have been set prior to sourcing it
    echo "Enter to deploy the resource. Control-C to exit."
    read ok
  
    echo "Execute the deploy script $SCRIPT_FILE_PATH"
   
    # this script depends on some of the variables set above
    source $SCRIPT_FILE_PATH

    echo "Do you want to deploy another resource? Enter to continue. Ctrl-C to exit."
    read ok
    
  done

 
}

if [ "$1" == "debug" ]; then DEBUG=1; echo "DEBUG ON"; fi

#run in function to protect local vars
run
