#!/bin/bash -e

create_deploy_script_resource_properties() {

    validate_first_n_args_set 5  "$@"
    
    local RESOURCE_TYPE="$1"
    local SCRIPT_FILE_PATH="$2"
    local TEMPLATE_FILE_PATH="$3"
    local SCHEMA_B64="$4"
  
    local SCHEMA=$(echo "$SCHEMA_B64" | base64 -d)
    local properties_json=$(jq -r 'if type == "string" then fromjson else . end | .properties' <<< "$SCHEMA")
    local readOnlyProps=$(jq -r 'if type == "string" then fromjson else . end | if has("readOnlyProperties") then .readOnlyProperties[] else empty end' <<< "$SCHEMA" | sed 's|/properties/||g')

     echo "echo ''" >>  "$SCRIPT_FILE_PATH"
     echo "echo \"Enter property values for $RESOURCE_TYPE:\""  >> "$SCRIPT_FILE_PATH"
     while read -r property; do
        
            if [ $DEBUG ]; then echo "Processing property: $property in script resource code"; fi
    
            # Check if property is in the read-only list
            if echo "$readOnlyProps" | grep -q "^$property$"; then
                #echo "# Skipping read-only property: $property" >> "$SCRIPT_FILE_PATH"
                continue
            fi
            
            echo "echo ''" >>  "$SCRIPT_FILE_PATH"
            
            local object_schema=""
            local description=""
            local type=""
            local required=""
            local enum_values=""
            local cf_type=""
            local param_type=""
            
            echo "echo \"Property: $property\"" >> "$SCRIPT_FILE_PATH"
            
            local description=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].description')
            echo "echo \"Description: $description\"" >> "$SCRIPT_FILE_PATH"
            
            local ref=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]["$ref"]')
            
            if [[ -n "$ref" && "$ref" != "null" ]]; then
                if [ $DEBUG ]; then echo "Processing complex type: $ref"; fi
                local object_schema=$(jq -r --arg defname "$property" 'fromjson | .definitions[$defname]' <<< "$SCHEMA") 
                local object_schema_b64=$(echo "$object_schema" | base64)
                
                create_deploy_script_resource_properties "$property" "$object_schema_b64" "$SCRIPT_FILE_PATH" "$TEMPLATE_FILE_PATH"
            else

                if [ $DEBUG ]; then  "Processing non-complex type"; fi
                param_type=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].type')
                if [ $DEBUG ]; then echo "echo \"Type: $param_type\"" >> "$SCRIPT_FILE_PATH"; fi
                
                # Map JSON Schema types to CloudFormation parameter types
                # Valid CF parameter types: String, Number, List, Comma Delimited List, AWS specific types (e.g. AWS::EC2::Image::Id)
                case "$param_type" in
                    "integer"|"number") cf_type="Number" ;;
                    "boolean") cf_type="String" ;;
                    "array") cf_type="CommaDelimitedList" ;;
                    "string") cf_type="String" ;;
                    *) echo "Other type: $param_type to String: $param_type"; cf_type="String" ;;
                esac
                if [ $DEBUG ]; then echo "CloudFormation Type: $cf_type"; fi
                
                local required=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]? // {} | .required? | index($prop) | (. >= 0) | tostring')

                if [[ "$required" == "true" ]]; then
                    echo "echo \"Required: Yes\"" >> "$SCRIPT_FILE_PATH"
                else
                    echo "echo \"Required: No\"" >> "$SCRIPT_FILE_PATH"
                fi
                
                local type=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].enum')

                
                if [[ -n "$enum_values" && "$enum_values" != "" && "$enum_values" != "null" ]]; then
                    echo "echo \"Allowed values: $enum_values\"" >> "$SCRIPT_FILE_PATH"
                    if [ $DEBUG ]; then echo "Enum: $enum_values"; fi
                else
                    if [ type == "boolean" ]; then 
                        if [[ "$required" == "true" ]]; then
                            echo "echo \"Allowed values: true, false\"" >> "$SCRIPT_FILE_PATH"
    
                        else
                            echo "echo \"Allowed values: true, false, <empty>\"" >> "$SCRIPT_FILE_PATH"
                        fi
                    fi
                fi
                
                echo "echo \"Enter value for $property:\"" >> "$SCRIPT_FILE_PATH"
                echo "read -r ${property}_value" >> "$SCRIPT_FILE_PATH"

                if [ $DEBUG ]; then echo "Add to parameter overrides"; fi
                echo "if [[ -n \"\${${property}_value}\" ]]; then" >> "$SCRIPT_FILE_PATH"
                echo " echo \"Property Value: \${${property}_value}\"" >> "$SCRIPT_FILE_PATH"
                echo "  # Handle special characters including @ in parameter values" >> "$SCRIPT_FILE_PATH"
                echo "  SAFE_VALUE=\$(printf '%q' \"\${${property}_value}\")" >> "$SCRIPT_FILE_PATH"
                echo "  echo \"SAFE_VALUE: $SAFE_VALUE\"" >> "$SCRIPT_FILE_PATH"
                echo "  if [[ -z \"\$PARAMETER_OVERRIDES\" ]]; then" >> "$SCRIPT_FILE_PATH"
                echo "    PARAMETER_OVERRIDES=\"$property=\$SAFE_VALUE\"" >> "$SCRIPT_FILE_PATH"
                echo "  else" >> "$SCRIPT_FILE_PATH"
                echo "    PARAMETER_OVERRIDES=\"\$PARAMETER_OVERRIDES $property=\$SAFE_VALUE\"" >> "$SCRIPT_FILE_PATH"
                echo "  fi" >> "$SCRIPT_FILE_PATH"
                echo "fi" >> "$SCRIPT_FILE_PATH"
                
            fi
            
            echo "" >> "$SCRIPT_FILE_PATH"
            
        done < <(echo "$properties_json" | jq -r 'keys[]')
    
}
