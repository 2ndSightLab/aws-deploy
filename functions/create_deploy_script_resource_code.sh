#!/bin/bash -e

create_deploy_script_resource_code() {
    local RESOURCE_TYPE="$1"
    local SCHEMA_B64="$2"
    local SCRIPT_FILE_PATH="$3"
    local TEMPLATE_FILE_PATH="$4"
    
    if [[ -z \"\$RESOURCE_TYPE\" ]]; then
       echo "Error: Resource type is not set."
       exit
    fi
    
    local SCHEMA=$(echo "$SCHEMA_B64" | base64 -d)
    local properties_json=$(jq -r 'if type == "string" then fromjson else . end | .properties' <<< "$SCHEMA")
    local readOnlyProps=$(jq -r 'if type == "string" then fromjson else . end | if has("readOnlyProperties") then .readOnlyProperties[] else empty end' <<< "$SCHEMA" | sed 's|/properties/||g')

     echo ""
     echo "echo \"Enter property values for $RESOURCE_TYPE:\""  >> "$SCRIPT_FILE_PATH"
     while read -r property; do

            #echo "Processing property: $property in script resource code"
        
            # Check if property is in the read-only list
            if echo "$readOnlyProps" | grep -q "^$property$"; then
                echo "# Skipping read-only property: $property" >> "$SCRIPT_FILE_PATH"
                continue
            fi
            
            local object_schema=""
            local description=""
            local type=""
            local required=""
            local enum_values=""

            local description=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].description')
            echo "echo \"Description: $description\"" >> "$SCRIPT_FILE_PATH"
            
            local ref=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]["$ref"]')
            
            if [[ -n "$ref" && "$ref" != "null" ]]; then
                #echo "Processing complex type: $ref"
                local object_schema=$(jq -r --arg defname "$property" 'fromjson | .definitions[$defname]' <<< "$SCHEMA") 
                local object_schema_b64=$(echo "$object_schema" | base64)
                create_deploy_script_resource_code "$property" "$object_schema_b64" "$SCRIPT_FILE_PATH" "$TEMPLATE_FILE_PATH"
            else

                #echo "Processing non-complex type"
                local type=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].type')
                echo "echo \"Type: $type\"" >> "$SCRIPT_FILE_PATH"
                #echo "Type: $type"
                
                local required=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]? // {} | .required? | index($prop) | (. >= 0) | tostring')
                if [[ "$required" == "true" ]]; then
                    echo "echo \"Required: Yes\"" >> "$SCRIPT_FILE_PATH"
                else
                    echo "echo \"Required: No\"" >> "$SCRIPT_FILE_PATH"
                fi
                #echo "Required: $required"
                
                local enum_values=$(echo "$properties_json" | jq -r --arg prop "$property" 'if .[$prop].enum | type == "array" then .[$prop].enum | join(";") else null end' 2>/dev/null || echo "")
                if [[ -n "$enum_values" && "$enum_values" != "" && "$enum_values" != "null" ]]; then
                    echo "echo \"Allowed values: $enum_values\"" >> "$SCRIPT_FILE_PATH"
                    #echo "Enum: $enum_values"
                #else
                #    echo "No enum"
                fi
                
                echo "echo \"Enter value for $property:\"" >> "$SCRIPT_FILE_PATH"
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

            #echo "$property complete"
            
        done < <(echo "$properties_json" | jq -r 'keys[]')
    
}
