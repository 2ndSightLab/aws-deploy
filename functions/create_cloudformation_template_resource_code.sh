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
    local properties_info=$(jq -r 'if type == "string" then fromjson else . end | .properties' <<< "$SCHEMA")
    local readOnlyProps=$(jq -r 'if type == "string" then fromjson else . end | if has("readOnlyProperties") then .readOnlyProperties[] else empty end' <<< "$SCHEMA" | sed 's|/properties/||g')

    for prop_info in $properties_info; do
        IFS=':' read -r prop_name prop_type is_required min_length <<< "$prop_info"
        if [ "$is_required" = "true" ] || [ "$min_length" -ge 1 ]; then
            # Required properties are always included
            echo "      $prop_name:" >> "$TEMPLATE_FILE_PATH"
            echo "        Ref: $prop_name" >> "$TEMPLATE_FILE_PATH"
        else
            # Optional properties are conditionally included
            echo "      $prop_name:" >> "$TEMPLATE_FILE_PATH"
            echo "        Fn::If:" >> "$TEMPLATE_FILE_PATH"
            echo "          - ${prop_name}Condition" >> "$TEMPLATE_FILE_PATH"
            echo "          - Ref: $prop_name" >> "$TEMPLATE_FILE_PATH"
            echo "          - Ref: AWS::NoValue" >> "$TEMPLATE_FILE_PATH"
        fi
    done
    echo "" >> "$TEMPLATE_FILE_PATH"

}
