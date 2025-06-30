#!/bin/bash -e
#this function cals generate_resource_code which recursively calls itself for sub resources
create_deploy_script_for_resource() {
    local SERVICE_NAME="$1"
    local RESOURCE_NAME="$2"
    
    local SCRIPT_FILE_PATH=$(get_script_file_path $SERVICE_NAME $RESOURCE_NAME)
    local TEMPLATE_FILE_PATH=$(get_template_file_path $SERVICE_NAME $RESOURCE_NAME)
    
    # Create the script file with shebang
    echo '#!/bin/bash -e' > "$SCRIPT_FILE_PATH"
    
    # Make the script executable
    chmod +x "$SCRIPT_FILE_PATH"

    # Set resource type directly
    RESOURCE_TYPE="AWS::$SERVICE_NAME::$RESOURCE_NAME"

    # Get properties, types, descriptions, enum values, and minimum lengths for the resource type
    SCHEMA=$(get_resource_schema $resource_type)

    SCHEMA_B64=$(echo "$SCHEMA_B64" | base64)
    
    # Generate the resource code
    create_deploy_script_resource_code "$RESOURCE_TYPE" "$SCHEMA_B64" "$SCRIPT_FILE_PATH" "$TEMPLATE_FILE_PATH"
    
    echo "Created deployment script at $SCRIPT_FILE_PATH"
}

