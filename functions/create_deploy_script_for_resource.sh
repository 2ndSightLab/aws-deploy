#!/bin/bash
create_deploy_script_for_resource(){
    local SERVICE_NAME="$1"
    local RESOURCE_NAME="$2"
    
    local SCRIPT_FILE_PATH=$(get_script_file_path $SERVICE_NAME $RESOURCE_NAME)
    local TEMPLATE_FILE_PATH=$(get_template_file_path $SERVICE_NAME $RESOURCE_NAME)
    
    # Create the script file with shebang
    echo '#!/bin/bash -e' > "$SCRIPT_FILE_PATH"
    
    # Make the script executable
    chmod +x "$SCRIPT_FILE_PATH"
    
    # Set resource type directly
    resource_type="AWS::$SERVICE_NAME::$RESOURCE_NAME"
    
    # Get properties for the resource type
    properties=$(aws cloudformation describe-type --type RESOURCE --type-name "$resource_type" | jq -r '.Schema' | jq -r '.properties | keys[]')
    
    # Add echo and read statements for each property
    for property in $properties; do
        echo "echo \"Please enter value for $property:\"" >> "$SCRIPT_FILE_PATH"
        echo "read -r ${property}_value" >> "$SCRIPT_FILE_PATH"
    done
    
    # Build parameter-overrides string for CloudFormation deploy
    echo "" >> "$SCRIPT_FILE_PATH"
    echo "# Build parameter-overrides string for CloudFormation deploy" >> "$SCRIPT_FILE_PATH"
    echo "PARAMETER_OVERRIDES=\"\"" >> "$SCRIPT_FILE_PATH"
    
    # Add conditional logic to only include parameters with values
    for property in $properties; do
        echo "if [[ -n \"\${${property}_value}\" ]]; then" >> "$SCRIPT_FILE_PATH"
        echo "  # Handle special characters including @ in parameter values" >> "$SCRIPT_FILE_PATH"
        echo "  SAFE_VALUE=\$(printf '%q' \"\${${property}_value}\")" >> "$SCRIPT_FILE_PATH"
        echo "  if [[ -z \"\$PARAMETER_OVERRIDES\" ]]; then" >> "$SCRIPT_FILE_PATH"
        echo "    PARAMETER_OVERRIDES=\"$property=\$SAFE_VALUE\"" >> "$SCRIPT_FILE_PATH"
        echo "  else" >> "$SCRIPT_FILE_PATH"
        echo "    PARAMETER_OVERRIDES=\"\$PARAMETER_OVERRIDES $property=\$SAFE_VALUE\"" >> "$SCRIPT_FILE_PATH"
        echo "  fi" >> "$SCRIPT_FILE_PATH"
        echo "fi" >> "$SCRIPT_FILE_PATH"
    done
    
    # Add base64 encoding of parameter overrides with proper handling of special characters
    echo "" >> "$SCRIPT_FILE_PATH"
    echo "# Base64 encode the parameter overrides" >> "$SCRIPT_FILE_PATH"
    echo "ENCODED_PARAMETERS=\$(echo -n \"\$PARAMETER_OVERRIDES\" | base64 -w 0)" >> "$SCRIPT_FILE_PATH"
    echo "echo \"\"" >> "$SCRIPT_FILE_PATH"
    echo "echo \"Base64 encoded parameters:\"" >> "$SCRIPT_FILE_PATH"
    echo "echo \"\$ENCODED_PARAMETERS\"" >> "$SCRIPT_FILE_PATH"
    
    # Set IAM_CAPABILITY variable based on resource type
    echo "" >> "$SCRIPT_FILE_PATH"
    echo "# Set IAM capability flag based on resource type" >> "$SCRIPT_FILE_PATH"
    echo "IAM_CAPABILITY=false" >> "$SCRIPT_FILE_PATH"
    
    # Check if resource type requires IAM permissions
    echo "# Check if resource requires IAM permissions" >> "$SCRIPT_FILE_PATH"
    echo "if [[ \"$resource_type\" == *\"IAM\"* || \"$resource_type\" == *\"Role\"* || \"$resource_type\" == *\"Policy\"* || \"$resource_type\" == *\"User\"* || \"$resource_type\" == *\"Group\"* ]]; then" >> "$SCRIPT_FILE_PATH"
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
    
    echo "# Deploy CloudFormation stack" >> "$SCRIPT_FILE_PATH"
    echo "deploy_cloudformation_stack \$STACK_NAME \$TEMPLATE_FILE_PATH \$ENCODED_PARAMETERS \$IAM_CAPABILITY" >> "$SCRIPT_FILE_PATH"
    
    echo "Created deployment script at $SCRIPT_FILE_PATH"
}

