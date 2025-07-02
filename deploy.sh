#!/bin/bash -e

echo "Initializing..."

#source all the files in the functions directory
for file in functions/*; do [ -f "$file" ] && source "$file"; done

ENV_NAME=""
ENV_DIR=""
ENV_FILE_PATH=""
GIT_REPO_URL=""
GIT_REPO_PARENT_DIR=""
GIT_REPO_DIR=""
GIT_REPO_NAME=""
ENV_PROFILE=""

source init/environment.sh

source init/git_repo.sh

source init/aws_profile.sh

source init/region.sh

source init/identity.sh

source init/service.sh

source init/service_resource.sh

source init/stack_name.sh

source init/stack_resource_name.sh

source init/aws_account_number.sh

source init/template_file_path.sh

source init/script_file_path.sh

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
