#!/bin/bash
create_cloudformation_template_parameter_code(){
    local RESOURCE_TYPE="$1"
    local SCHEMA_B64="$2"
    local TEMPLATE_FILE_PATH="$3"
    
   # Add Parameters
    echo "Parameters:" >> "$TEMPLATE_FILE_PATH"
    if [[ -z \"\$RESOURCE_TYPE\" ]]; then
       echo "Error: Resource type is not set."
       exit
    fi
    
    local SCHEMA=$(echo "$SCHEMA_B64" | base64 -d)
    local properties_info=$(jq -r 'if type == "string" then fromjson else . end | .properties' <<< "$SCHEMA")
    local readOnlyProps=$(jq -r 'if type == "string" then fromjson else . end | if has("readOnlyProperties") then .readOnlyProperties[] else empty end' <<< "$SCHEMA" | sed 's|/properties/||g')
    
    for prop_info in $properties_info; do
    
        # Check if property is in the read-only list
        if echo "$readOnlyProps" | grep -q "^$property$"; then
            echo "# Skipping read-only property: $property" >> "$SCRIPT_FILE_PATH"
            continue
        fi

        IFS=':' read -r prop_name prop_type is_required min_length <<< "$prop_info"
        
        # Consider property required if is_required is true or min_length is 1 or more
        if [ "$is_required" = "true" ] || [ "$min_length" -ge 1 ]; then
            is_effectively_required="true"
        else
            is_effectively_required="false"
        fi
        
        # Map JSON Schema types to CloudFormation parameter types
        case "$prop_type" in
            "integer"|"number") cf_type="Number" ;;
            "boolean") cf_type="String"; echo "    AllowedValues: [true, false]" >> "$TEMPLATE_FILE_PATH" ;;
            "array") cf_type="CommaDelimitedList" ;;
            *) cf_type="String" ;;
        esac
        
        echo "  $prop_name:" >> "$TEMPLATE_FILE_PATH"
        echo "    Type: ${cf_type}" >> "$TEMPLATE_FILE_PATH"
        if [ "$is_effectively_required" = "true" ]; then
            echo "    Description: Required - Enter value for ${prop_name}" >> "$TEMPLATE_FILE_PATH"
        else
            echo "    Description: Optional - Enter value for ${prop_name}" >> "$TEMPLATE_FILE_PATH"
            echo "    Default: ''" >> "$TEMPLATE_FILE_PATH"
        fi
    done
    echo "" >> "$TEMPLATE_FILE_PATH"
    
}
