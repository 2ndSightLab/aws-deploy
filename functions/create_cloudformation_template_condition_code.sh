#!/bin/bash -e
create_cloudformation_template_condition_code(){
    local RESOURCE_TYPE="$1"
    local SCHEMA_B64="$2"
    local SCRIPT_FILE_PATH="$3"
    local TEMPLATE_FILE_PATH="$4"
    
    # Add Conditions with proper handling for array types and full function names
    echo "Conditions:" >> "$TEMPLATE_FILE_PATH"
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
