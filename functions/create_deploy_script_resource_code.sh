#!/bin/bash -e
# Function to generate resource code and write it to the script file
create_deploy_script_resource_code() {
    local RESOURCE_TYPE="$1"
    local SCHEMA_B64="$2"
    local SCRIPT_FILE_PATH="$3"
    local TEMPLATE_FILE_PATH="$4"
    
    # Decode the base64 encoded schema
   
    if [[ -z \"\$RESOURCE_TYPE\" ]]; then
       echo "Error: Resource type is not set."
       exit
    fi
    
    local SCHEMA=$(echo "$SCHEMA_B64" | base64 -d)

    properties_json=$(jq -r 'if type == "string" then fromjson else . end | .properties' <<< "$SCHEMA")

     while read -r property; do
            
            echo "Processing property: $property"
            description=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].description')
                
            ref=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]["$ref"]')
            
            if [[ -n "$ref" && "$ref" != "null" ]]; then

                echo "Processing complex type: $ref"
                object_schema=$(jq -r --arg defname "$property" 'fromjson | .definitions[$defname]' <<< "$SCHEMA") 
                object_schema_b64=$(echo "$object_schema" | base64)
                create_deploy_script_resource_code "$property" "$object_schema_b64" "$SCRIPT_FILE_PATH" "$TEMPLATE_FILE_PATH"
            else

                echo "Processing non-complex type"
                type=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].type')
                echo "echo \"Type: $type\"" >> "$SCRIPT_FILE_PATH"
                echo "Type: $type"
                
                required=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]? // {} | .required? | index($prop) | (. >= 0) | tostring')
                if [[ "$required" == "true" ]]; then
                    echo "echo \"Required: Yes\"" >> "$SCRIPT_FILE_PATH"
                else
                    echo "echo \"Required: No\"" >> "$SCRIPT_FILE_PATH"
                fi
                echo "Required: $required"
                
                enum_values=$(echo "$properties_json" | jq -r --arg prop "$property" 'if .[$prop].enum | type == "array" then .[$prop].enum | join(";") else null end' 2>/dev/null || echo "")
                if [[ -n "$enum_values" && "$enum_values" != "null" ]]; then
                    echo "echo \"Allowed values: $enum_values\"" >> "$SCRIPT_FILE_PATH"
                    echo "Enum: $enum_values"
                else
                    echo "No enum"
                fi
                
                echo "echo \"Please enter value for $property:\"" >> "$SCRIPT_FILE_PATH"
                echo "read -r ${property}_value" >> "$SCRIPT_FILE_PATH"

                # Add to parameter overrides
                echo "if [[ -n \"\${${property}_value}\" ]]; then" >> "$SCRIPT_FILE_PATH"
                echo "  # Handle special characters including @ in parameter values" >> "$SCRIPT_FILE_PATH"
                echo "  SAFE_VALUE=\$(printf '%q' \"\${${property}_value}\")" >> "$SCRIPT_FILE_PATH"
                echo "  if [[ -z \"\$PARAMETER_OVERRIDES\" ]]; then" >> "$SCRIPT_FILE_PATH"
                echo "    PARAMETER_OVERRIDES=\"$property=\$SAFE_VALUE\"" >> "$SCRIPT_FILE_PATH"
                echo "  else" >> "$SCRIPT_FILE_PATH"
                echo "    PARAMETER_OVERRIDES=\"\$PARAMETER_OVERRIDES $property=\$SAFE_VALUE\"" >> "$SCRIPT_FILE_PATH"
                echo "  fi" >> "$SCRIPT_FILE_PATH"
                echo "fi" >> "$SCRIPT_FILE_PATH"
            fi
            
            echo "" >> "$SCRIPT_FILE_PATH"

            echo "$property complete"
            
        done < <(echo "$properties_json" | jq -r 'keys[]')
    
}
