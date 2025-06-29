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
    
    # Generate the resource code
    generate_resource_code "$SERVICE_NAME" "$RESOURCE_NAME" "$SCRIPT_FILE_PATH" "$TEMPLATE_FILE_PATH"
    
    echo "Created deployment script at $SCRIPT_FILE_PATH"
}

