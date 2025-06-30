#!/bin/bash
create_cloudformation_template_parameter_code(){
    local RESOURCE_TYPE="$1"
    local SCHEMA_B64="$2"
    local TEMPLATE_FILE_PATH="$3"
    
    if [[ -z \"\$RESOURCE_TYPE\" ]]; then
       echo "Error: Resource type is not set."
       exit
    fi

    local SCHEMA=$(echo "$SCHEMA_B64" | base64 -d)
    local properties_json=$(jq -r 'if type == "string" then fromjson else . end | .properties' <<< "$SCHEMA") 
    local readOnlyProps=$(jq -r 'if type == "string" then fromjson else . end | if has("readOnlyProperties") then .readOnlyProperties[] else empty end' <<< "$SCHEMA" | sed 's|/properties/||g')
    
     while read -r property; do
        
        local cf_type=""
        local param_type=""
        local required=""
        local ref=""
        local object_schema=""

        #echo "Processing property: $property in parameters"
        if echo "$readOnlyProps" | grep -q "^$property$"; then
            continue
        fi

        local ref=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]["$ref"]')
 
        if [[ -n "$ref" && "$ref" != "null" ]]; then
            #echo "Processing complex type: $ref"
            object_schema=$(jq -r --arg defname "$property" 'fromjson | .definitions[$defname]' <<< "$SCHEMA") 
            object_schema_b64=$(echo "$object_schema" | base64)
            create_cloudformation_template_parameter_code "$property" "$object_schema_b64" "$TEMPLATE_FILE_PATH"
        else
            local param_type=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].type')
            local required=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]? // {} | .required? | index($prop) | (. >= 0) | tostring')
            
            # Map JSON Schema types to CloudFormation parameter types
            # Valid CF parameter types: String, Number, List, Comma Delimited List, AWS specific types (e.g. AWS::EC2::Image::Id)
            case "$param_type" in
                "integer"|"number") cf_type="Number" ;;
                "boolean") 
                     cf_type="String"; 
                     if [[ "$required" == "true" ]]; then
                        echo "    AllowedValues: [true, false]" >> "$TEMPLATE_FILE_PATH" ;;
                     else
                        echo "    AllowedValues: [true, false, '']" >> "$TEMPLATE_FILE_PATH" ;;
                     fi
                "array") cf_type="CommaDelimitedList" ;;
                *) echo "Other type to String: $param_type"; cf_type="String" ;;
            esac
            
            echo "  $property:" >> "$TEMPLATE_FILE_PATH"
            echo "    Type: ${cf_type}" >> "$TEMPLATE_FILE_PATH"
            
            if [[ "$required" == "true" ]]; then
                echo "    Description: Required - Enter value for ${property}" >> "$TEMPLATE_FILE_PATH"
            else
                echo "    Description: Optional - Enter value for ${property}" >> "$TEMPLATE_FILE_PATH"
                echo "    Default: ''" >> "$TEMPLATE_FILE_PATH"
            fi
        fi
        
    done < <(echo "$properties_json" | jq -r 'keys[]')
    echo "" >> "$TEMPLATE_FILE_PATH"
    
}
