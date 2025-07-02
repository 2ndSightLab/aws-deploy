#!/bin/bash -e

create_cloudformation_template_resource_code(){
    
    validate_first_n_args_set 3  "$@"

    local RESOURCE_TYPE="$1"
    local SCHEMA_B64="$2"
    local TEMPLATE_FILE_PATH="$3"
    local indent="$4"
        
    local SCHEMA=$(echo "$SCHEMA_B64" | base64 -d)
    local properties_json=$(jq -r 'if type == "string" then fromjson else . end | .properties' <<< "$SCHEMA") 
    local readOnlyProps=$(jq -r 'if type == "string" then fromjson else . end | if has("readOnlyProperties") then .readOnlyProperties[] else empty end' <<< "$SCHEMA" | sed 's|/properties/||g')
    
    while read -r property; do
    
      if echo "$readOnlyProps" | grep -q "^$property$"; then continue; fi
   
      local required=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]? // {} | .required? | index($prop) | (. >= 0) | tostring')

      #always print property name
      echo "$indent      $property:" >> "$TEMPLATE_FILE_PATH"

      local ref=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]["$ref"]')
 
        if [[ -n "$ref" && "$ref" != "null" ]]; then
            
            #echo "Processing complex type: $ref"
            local object_schema=$(jq -r --arg defname "$property" 'fromjson | .definitions[$defname]' <<< "$SCHEMA") 
            local object_schema_b64=$(echo "$object_schema" | base64)
            create_cloudformation_template_resource_code "$property" "$object_schema_b64" "$TEMPLATE_FILE_PATH" "$indent  "
            
        else
            local type=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].type')
            if [[ "$required" == "true" ]]; then   
                # Required properties are always included
                echo "$indent        Ref: $property" >> "$TEMPLATE_FILE_PATH"
            else
                # Optional properties are conditionally included
                echo "$indent        Fn::If:" >> "$TEMPLATE_FILE_PATH"
                echo "$indent          - ${property}Condition" >> "$TEMPLATE_FILE_PATH"
                echo "$indent          - Ref: $property" >> "$TEMPLATE_FILE_PATH"
                echo "$indent          - Ref: AWS::NoValue" >> "$TEMPLATE_FILE_PATH"
            fi
        fi
    done < <(echo "$properties_json" | jq -r 'keys[]')
    echo "" >> "$TEMPLATE_FILE_PATH"

}
