#!/bin/bash -e

create_cloudformation_template_resource_code(){
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
      if echo "$readOnlyProps" | grep -q "^$property$"; then
         echo "Skipping read-only property: $property" 
         continue
      fi

      local ref=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]["$ref"]')
 
        if [[ -n "$ref" && "$ref" != "null" ]]; then
            echo "Processing complex type: $ref"
            local object_schema=$(jq -r --arg defname "$property" 'fromjson | .definitions[$defname]' <<< "$SCHEMA") 
            local object_schema_b64=$(echo "$object_schema" | base64)
            create_cloudformation_template_resource_code "$property" "$object_schema_b64" "$TEMPLATE_FILE_PATH"
        else
            local type=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop].type')
            local required=$(echo "$properties_json" | jq -r --arg prop "$property" '.[$prop]? // {} | .required? | index($prop) | (. >= 0) | tostring')
            if [[ "$required" == "true" ]]; then   
    
                # Required properties are always included
                echo "      $property:" >> "$TEMPLATE_FILE_PATH"
                echo "        Ref: $property" >> "$TEMPLATE_FILE_PATH"
            else
                # Optional properties are conditionally included
                echo "      $property:" >> "$TEMPLATE_FILE_PATH"
                echo "        Fn::If:" >> "$TEMPLATE_FILE_PATH"
                echo "          - ${property}Condition" >> "$TEMPLATE_FILE_PATH"
                echo "          - Ref: $property" >> "$TEMPLATE_FILE_PATH"
                echo "          - Ref: AWS::NoValue" >> "$TEMPLATE_FILE_PATH"
            fi
        fi
    done < <(echo "$properties_json" | jq -r 'keys[]')
    echo "" >> "$TEMPLATE_FILE_PATH"

}
