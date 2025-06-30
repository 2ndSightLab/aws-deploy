#!/bin/bash -e
# Function to generate resource code and write it to the script file
create_deploy_script_resource_code() {
    local RESOURCE_TYPE="$1"
    local SCHEMA="$2"
    local SCRIPT_FILE_PATH="$3"
    local TEMPLATE_FILE_PATH="$4"
 
    properties_json=$(jq -r 'fromjson | .properties' <<< "$SCHEMA")
    echo "Properties JSON for $RESOURCE_TYPE: $properties_json"

    while read -r property; do
        description=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].description // "No description available"')
        echo "echo \"Description: $description\"" >> "$SCRIPT_FILE_PATH"
        
        ref=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]["$ref"] // ""')
        
        if [[ -n "$ref" && "$ref" != "null" ]]; then
            echo "echo \"This property is a complex object type with reference: $ref\"" >> "$SCRIPT_FILE_PATH"
            
            definition_name=${ref#*#/definitions/}
            object_schema=$(jq -r --arg defname "$definition_name" 'fromjson | .definitions[$defname] // {}' <<< "$SCHEMA")
            
            echo "create_deploy_script_resource_code \"$object_schema\" \"$property\" \"$SCRIPT_FILE_PATH\" \"$TEMPLATE_FILE_PATH\"" >> "$SCRIPT_FILE_PATH"
        else
            type=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].type // ""')
            echo "echo \"Type: $type\"" >> "$SCRIPT_FILE_PATH"
            
            required=$(jq -r --arg prop "$property" 'fromjson | .required | contains([$prop]) | tostring' <<< "$SCHEMA")
            if [[ "$required" == "true" ]]; then
                echo "echo \"Required: Yes\"" >> "$SCRIPT_FILE_PATH"
            else
                echo "echo \"Required: No\"" >> "$SCRIPT_FILE_PATH"
            fi
            
            enum_values=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].enum | join(";")' 2>/dev/null || echo "")
            if [[ -n "$enum_values" && "$enum_values" != "null" ]]; then
                echo "echo \"Allowed values: $enum_values\"" >> "$SCRIPT_FILE_PATH"
            fi
            
            echo "echo \"Please enter value for $property:\"" >> "$SCRIPT_FILE_PATH"
            echo "read -r ${property}_value" >> "$SCRIPT_FILE_PATH"
        fi
    
        echo "" >> "$SCRIPT_FILE_PATH"
    done < <(echo "$properties_json" | jq -r 'keys[]')

    # Add conditional logic to only include parameters with values
    echo "$properties" | while IFS='|' read -r property type description enum_values min_length; do
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
    
    # Deploy CloudFormation stack
    echo "# Deploy CloudFormation stack" >> "$SCRIPT_FILE_PATH"
    echo "deploy_cloudformation_stack \$STACK_NAME \$TEMPLATE_FILE_PATH \$ENCODED_PARAMETERS \$IAM_CAPABILITY" >> "$SCRIPT_FILE_PATH"
}
