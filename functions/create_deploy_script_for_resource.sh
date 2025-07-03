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

    # Set IAM_CAPABILITY variable based on resource type
    echo "" >> "$SCRIPT_FILE_PATH"
    echo "# Set IAM capability flag based on resource type" >> "$SCRIPT_FILE_PATH"
    echo "IAM_CAPABILITY=false" >> "$SCRIPT_FILE_PATH"
    
    create_deploy_script_resource_properties "$RESOURCE_TYPE" "$SCRIPT_FILE_PATH" "$TEMPLATE_FILE_PATH" "$SCHEMA_B64" "$IAM_CAPABILITY"
    
    # Check if resource type requires IAM permissions with more precise matching
    echo "# Check if resource requires IAM permissions" >> "$SCRIPT_FILE_PATH"
    echo "if [[ \"$RESOURCE_TYPE\" == \"AWS::IAM::\"* ]]; then" >> "$SCRIPT_FILE_PATH"
    echo "  IAM_CAPABILITY=true" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"This resource requires IAM capabilities for deployment.\"" >> "$SCRIPT_FILE_PATH"
    echo "fi" >> "$SCRIPT_FILE_PATH"
   
    echo "Created deployment script at $SCRIPT_FILE_PATH"
    
}

