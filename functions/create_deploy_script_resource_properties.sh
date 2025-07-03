#!/bin/bash -e

create_deploy_script_resource_properties() {

    validate_first_n_args_set 5  "$@"
    
    local RESOURCE_TYPE="$1"
    local SCRIPT_FILE_PATH="$2"
    local TEMPLATE_FILE_PATH="$3"
    local SCHEMA_B64="$4"
    local IAM_CAPABILITY="$5"
    
    local SCHEMA=$(echo "$SCHEMA_B64" | base64 -d)
    local properties_json=$(jq -r 'if type == "string" then fromjson else . end | .properties' <<< "$SCHEMA")
    local readOnlyProps=$(jq -r 'if type == "string" then fromjson else . end | if has("readOnlyProperties") then .readOnlyProperties[] else empty end' <<< "$SCHEMA" | sed 's|/properties/||g')

     echo "echo ''" >>  "$SCRIPT_FILE_PATH"
     echo "echo \"Enter property values for $RESOURCE_TYPE:\""  >> "$SCRIPT_FILE_PATH"
     while read -r property; do
        
            #echo "Processing property: $property in script resource code"
    
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
            
            #echo "Property: $property"
            
            local description=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].description')
            description_b64=$(echo $description | base64 -w 0)
            echo "description_b64=$description_b64" >>  "$SCRIPT_FILE_PATH"
            echo "echo \"Description:\"" >> "$SCRIPT_FILE_PATH"
            echo "echo $description_b64 | base64 -d"
            local ref=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]["$ref"]')
            
            if [[ -n "$ref" && "$ref" != "null" ]]; then
                #echo "Processing complex type: $ref"
                local object_schema=$(jq -r --arg defname "$property" 'fromjson | .definitions[$defname]' <<< "$SCHEMA") 
                local object_schema_b64=$(echo "$object_schema" | base64)
                create_deploy_script_resource_properties "$property" "$object_schema_b64" "$SCRIPT_FILE_PATH" "$TEMPLATE_FILE_PATH"
            else

                #echo "Processing non-complex type"
                param_type=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].type')
                echo "echo \"Type: $param_type\"" >> "$SCRIPT_FILE_PATH"
                
                # Map JSON Schema types to CloudFormation parameter types
                # Valid CF parameter types: String, Number, List, Comma Delimited List, AWS specific types (e.g. AWS::EC2::Image::Id)
                case "$param_type" in
                    "integer"|"number") cf_type="Number" ;;
                    "boolean") cf_type="String"; echo "    AllowedValues: [true, false]" >> "$TEMPLATE_FILE_PATH" ;;
                    "array") cf_type="CommaDelimitedList" ;;
                    "string") cf_type="String" ;;
                    *) echo "Other type: $param_type to String: $param_type"; cf_type="String" ;;
                esac
                #echo "CloudFormation Type: $cf_type"
                
                local required=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]? // {} | .required? | index($prop) | (. >= 0) | tostring')

                if [[ "$required" == "true" ]]; then
                    echo "echo \"Required: Yes\"" >> "$SCRIPT_FILE_PATH"
                else
                    echo "echo \"Required: No\"" >> "$SCRIPT_FILE_PATH"
                fi
                
                local type=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].enum')

                
                if [[ -n "$enum_values" && "$enum_values" != "" && "$enum_values" != "null" ]]; then
                    echo "echo \"Allowed values: $enum_values\"" >> "$SCRIPT_FILE_PATH"
                    #echo "Enum: $enum_values"
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

                # Add to parameter overrides
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
            
    
}
