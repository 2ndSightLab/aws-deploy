#!/bin/bash -e
create_deploy_script_for_resource() {

    validate_first_n_args_set 7 "$@"

    local RESOURCE_TYPE="$1"
    local SCRIPT_FILE_PATH="$2"
    local TEMPLATE_FILE_PATH="$3"
    local ENV_PROFILE="$4"
    local REGION="$5"
    local SCHEMA_B64="$6"
    local STACK_NAME="$7"
    
    echo '#!/bin/bash -e' > "$SCRIPT_FILE_PATH"
    chmod +x "$SCRIPT_FILE_PATH"
    
    #this function loop sthrough properties and adds them to the file 
    create_deploy_script_resource_properties "$RESOURCE_TYPE" "$SCRIPT_FILE_PATH" "$TEMPLATE_FILE_PATH" "$SCHEMA_B64" "$IAM_CAPABILITY"

    # Set IAM_CAPABILITY variable based on resource type
    echo "" >> "$SCRIPT_FILE_PATH"
    echo "# Set IAM capability flag based on resource type" >> "$SCRIPT_FILE_PATH"
    echo "IAM_CAPABILITY=false" >> "$SCRIPT_FILE_PATH"

    # Check if resource type requires IAM permissions with more precise matching
    echo "# Check if resource requires IAM permissions" >> "$SCRIPT_FILE_PATH"
    echo "if [[ \"$RESOURCE_TYPE\" == \"AWS::IAM::\"* ]]; then" >> "$SCRIPT_FILE_PATH"
    echo "  IAM_CAPABILITY=true" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"This resource requires IAM capabilities for deployment.\"" >> "$SCRIPT_FILE_PATH"
    echo "fi" >> "$SCRIPT_FILE_PATH"
    
    #The code below is inserted after in the file and can reference variables already added in the above function
    echo "if [[ -z \"\$PARAMETER_OVERRIDES\" ]]; then" >> "$SCRIPT_FILE_PATH"
    echo "  read -p \"No parameters provided. Continue? (y/n): \" REPLY " >> "$SCRIPT_FILE_PATH"
    echo "  [[ ! \$REPLY =~ ^[Yy]$ ]] && exit 1" >> "$SCRIPT_FILE_PATH"
    echo "else" >> "$SCRIPT_FILE_PATH"
    echo "  # Add base64 encoding of parameter overrides with proper handling of special characters" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"\"" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"# Base64 encode the parameter overrides\"" >> "$SCRIPT_FILE_PATH"
    echo "  PARAMETER_OVERRIDES_B64=\$(echo -n \"\$PARAMETER_OVERRIDES\" | base64 -w 0)" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"\"" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"Base64 encoded parameters:\"" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"\$PARAMETER_OVERRIDES_B64\"" >> "$SCRIPT_FILE_PATH"
    echo "fi" >> "$SCRIPT_FILE_PATH"
        
    #create the stack file
    echo "create_stack_file \
     $RESOURCE_TYPE \   
     $STACK_NAME \
     $ENV_PROFILE \
     $REGION \
     $TEMPLATE_FILE_PATH \
     $SCRIPT_FILE_PATH \
     $IAM_CAPABILITY \
     $PARAMETER_OVERRIDES_B64" >> "$SCRIPT_FILE_PATH"
     
    # Add template file existence check
    echo "# Check if CloudFormation template file exists" >> "$SCRIPT_FILE_PATH"
    echo "if [[ ! -f \"$TEMPLATE_FILE_PATH\" ]]; then" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"Error: CloudFormation template file not found at $TEMPLATE_FILE_PATH\" >&2" >> "$SCRIPT_FILE_PATH"
    echo "  exit 1" >> "$SCRIPT_FILE_PATH"
    echo "fi" >> "$SCRIPT_FILE_PATH"
    echo "" >> "$SCRIPT_FILE_PATH"
     
    # Deploy CloudFormation stack
    echo "# Deploy CloudFormation stack" >> "$SCRIPT_FILE_PATH"
    echo "if [[ -z \"\$PARAMETER_OVERRIDES\" ]]; then" >> "$SCRIPT_FILE_PATH"
    echo "  deploy_cloudformation_stack \$STACK_NAME \$TEMPLATE_FILE_PATH \$ENV_PROFILE \$REGION \"\" \$IAM_CAPABILITY " >> "$SCRIPT_FILE_PATH"
    echo "else" >> "$SCRIPT_FILE_PATH"
    echo "  deploy_cloudformation_stack \$STACK_NAME \$TEMPLATE_FILE_PATH \$ENV_PROFILE \$REGION \$PARAMETER_OVERRIDES_B64 \$IAM_CAPABILITY " >> "$SCRIPT_FILE_PATH"
    echo "fi" >> "$SCRIPT_FILE_PATH"
    echo "Created deployment script at $SCRIPT_FILE_PATH"
    
}

