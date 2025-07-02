#!/bin/bash -e
#this function cals generate_resource_code which recursively calls itself for sub resources
create_deploy_script_for_resource() {

    validate_first_n_args_set 4  "$@"
    
    local SERVICE_NAME="$1"
    local RESOURCE_NAME="$2"
    local ENV_PROFILE="$3"
    local REGION="$4"

    local SCRIPT_FILE_PATH=$(get_script_file_path $SERVICE_NAME $RESOURCE_NAME)
    local TEMPLATE_FILE_PATH=$(get_template_file_path $SERVICE_NAME $RESOURCE_NAME)
    
    # Create the script file with shebang
    echo '#!/bin/bash -e' > "$SCRIPT_FILE_PATH"
    
    # Make the script executable
    chmod +x "$SCRIPT_FILE_PATH"

    # Set resource type directly
    local RESOURCE_TYPE="AWS::$SERVICE_NAME::$RESOURCE_NAME"

    # Get properties, types, descriptions, enum values, and minimum lengths for the resource type
    local SCHEMA=$(get_resource_schema $RESOURCE_TYPE $ENV_PROFILE $REGION)

    local SCHEMA_B64=$(echo "$SCHEMA" | base64)
    
    # Generate the resource code
    create_deploy_script_resource_properties "$RESOURCE_TYPE" "$SCHEMA_B64" "$SCRIPT_FILE_PATH" "$TEMPLATE_FILE_PATH"

    echo "if [[ -z \"\$PARAMETER_OVERRIDES\" ]]; then" >> "$SCRIPT_FILE_PATH"
    echo "  read -p \"No parameters provided. Continue? (y/n): \" -n 1 -r" >> "$SCRIPT_FILE_PATH"
    echo "  [[ ! \$REPLY =~ ^[Yy]$ ]] && exit 1" >> "$SCRIPT_FILE_PATH"
    echo "else" >> "$SCRIPT_FILE_PATH"
    echo "  # Add base64 encoding of parameter overrides with proper handling of special characters" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"\"" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"# Base64 encode the parameter overrides\"" >> "$SCRIPT_FILE_PATH"
    echo "  ENCODED_PARAMETERS=\$(echo -n \"\$PARAMETER_OVERRIDES\" | base64 -w 0)" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"\"" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"Base64 encoded parameters:\"" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"\$ENCODED_PARAMETERS\"" >> "$SCRIPT_FILE_PATH"
    echo "fi" >> "$SCRIPT_FILE_PATH"
    
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
    echo "  deploy_cloudformation_stack \$STACK_NAME \$TEMPLATE_FILE_PATH \$ENV_PROFILE \$REGION \$ENCODED_PARAMETERS \$IAM_CAPABILITY " >> "$SCRIPT_FILE_PATH"
    echo "fi" >> "$SCRIPT_FILE_PATH"
   
    echo "Created deployment script at $SCRIPT_FILE_PATH"
}

