#!/bin/bash -e
create_cloudformation_template_parameter_code(){

    validate_first_n_args_set 3 "$@"
    
    local RESOURCE_TYPE=$1
    local TEMPLATE_FILE_PATH=$2
    local SCHEMA_B64=$3
    
    local SCHEMA=$(echo "$SCHEMA_B64" | base64 -d)
    if [ -z "$SCHEMA" ]; then echo "Error: $SCHEMA is empty generating template parameter code"; exit; fi
  
    echo "Create CloudFormation template parameter code"

    local properties_json=$(jq -r 'if type == "string" then fromjson else . end | .properties' <<< "$SCHEMA") 
    local readOnlyProps=$(jq -r 'if type == "string" then fromjson else . end | if has("readOnlyProperties") then .readOnlyProperties[] else empty end' <<< "$SCHEMA" | sed 's|/properties/||g')

    #echo "Properties json:"
    #echo $properties_json | jq '.'
    
     while read -r property; do

        pcode=""
        
        local pjson=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]')
        echo "Processing property:"
        echo $pjson | jq .
        
        if echo "$readOnlyProps" | grep -q "^$property$"; then
            continue
        fi
        
        local cf_type=""
        local param_type=""
        local required=""
        local ref=""
        local object_schema=""
        local allowed_values=""
        local default_value=""

        local ref=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]["$ref"]')
 
        if [[ -n "$ref" && "$ref" != "null" ]]; then
            #echo "Processing complex type: $ref"
            object_schema=$(jq -r --arg defname "$property" 'fromjson | .definitions[$defname]' <<< "$SCHEMA") 
            object_schema_b64=$(echo "$object_schema" | base64)
            create_cloudformation_template_parameter_code "$property" "$object_schema_b64" "$TEMPLATE_FILE_PATH"
        else
           #echo "processing simple type"
           param_type=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].type')
           required=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]? // {} | .required? | index($prop) | (. >= 0) | tostring')
            
            # Map JSON Schema types to CloudFormation parameter types
            # Valid CF parameter types: String, Number, List, Comma Delimited List, AWS specific types (e.g. AWS::EC2::Image::Id)
        
           case "$param_type" in
                "integer"|"number") 
                    cf_type="Number" 
                    ;;
                "boolean")
                    cf_type="String" 
                    ;;
                "array") 
                    cf_type="CommaDelimitedList" 
                    ;;
                *) 
                    cf_type="String"
                    ;;
            esac
            
            #if required is false default value is '' and the property will not 
            #be set. When reading the parameter list, don't add properties set to 
            #'' to the property list
            if [ "$required" != "true" ]; then
                default_value="    Default: ''"
            fi

            # get allowed values from enum
            allowed_values=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].enum')
 
            #default allowed value list for boolean
            #if [ "$param_type" ==

            if [[ "$required" == "true" ]]; then required="Required"; else required="Optional"; fi

            if [ "$allowed_values" != "" ]; then 
                allowed_values="    AllowedValues: $allowed_values" 
            fi
            
            echo "  $property:" >> "$TEMPLATE_FILE_PATH"
            echo "    Type: ${cf_type}" >> "$TEMPLATE_FILE_PATH"
            echo "    Description: $required - Enter value for ${property}" >> "$TEMPLATE_FILE_PATH"
            echo $default_value
            echo $allowed_values
          
        fi
        
    done < <(echo "$properties_json" | jq -r 'keys[]')
    echo "" >> "$TEMPLATE_FILE_PATH"
    
}
