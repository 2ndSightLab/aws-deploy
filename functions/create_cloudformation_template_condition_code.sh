#!/bin/bash -e
create_cloudformation_template_condition_code(){
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
        # Only create conditions for optional properties
        if [ "$is_required" = "false" ] && [ "$min_length" -lt 1 ]; then
            echo "  ${prop_name}Condition:" >> "$TEMPLATE_FILE_PATH"
            if [ "$prop_type" = "array" ]; then
                # For array types, check if the array is empty using Fn::Join
                echo "    Fn::Not:" >> "$TEMPLATE_FILE_PATH"
                echo "      - Fn::Equals:" >> "$TEMPLATE_FILE_PATH"
                echo "          - Fn::Join:" >> "$TEMPLATE_FILE_PATH"
                echo "              - ''" >> "$TEMPLATE_FILE_PATH"
                echo "              - Ref: $prop_name" >> "$TEMPLATE_FILE_PATH"
                echo "          - ''" >> "$TEMPLATE_FILE_PATH"
            else
                # For non-array types, check if the value is not empty
                echo "    Fn::Not:" >> "$TEMPLATE_FILE_PATH"
                echo "      - Fn::Equals:" >> "$TEMPLATE_FILE_PATH"
                echo "          - Ref: $prop_name" >> "$TEMPLATE_FILE_PATH"
                echo "          - ''" >> "$TEMPLATE_FILE_PATH"
            fi
        fi
    done
    echo "" >> "$TEMPLATE_FILE_PATH"

}
