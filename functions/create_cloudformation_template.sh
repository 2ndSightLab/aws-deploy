#!/bin/bash
create_cloudformation_template() {
    local SERVICE_NAME="$1"
    local RESOURCE_NAME="$2"
    local TEMPLATE_FILE_PATH=$(get_template_file_path $SERVICE_NAME $RESOURCE_NAME)

    # Construct the resource type directly
    resource_type="AWS::$SERVICE_NAME::$RESOURCE_NAME"

    # Extract properties from the Schema, including minLength
    #local schema=$(aws cloudformation describe-type --type RESOURCE --type-name "$resource_type" | jq -r '.Schema')
    local schema=$(get_resource_schema $resource_type)
    #local properties_info=$(echo "$schema" | jq -r '.properties | to_entries[] | "\(.key):\(.value.type // "String"):\(.value.required // false):\(.value.minLength // 0)"' || echo "$schema" | jq -r 'fromjson | .properties | to_entries[] | "\(.key):\(.value.type // "String"):\(.value.required // false):\(.value.minLength // 0)"')
    local properts_info=$(get_resource_properties_json_from $scema)
    #local readOnlyProps=$(jq -r 'if type == "string" then fromjson else . end | if has("readOnlyProperties") then .readOnlyProperties[] else empty end' <<< "$SCHEMA" | sed 's|/properties/||g')
    local readOnlyProps=$(get_read_only_properties $SCHEMA)
 
    # Start the template
    echo "AWSTemplateFormatVersion: '2010-09-09'" > "$TEMPLATE_FILE_PATH"
    echo "Description: CloudFormation template for $SERVICE_NAME $RESOURCE_NAME" >> "$TEMPLATE_FILE_PATH"
    echo "" >> "$TEMPLATE_FILE_PATH"

    #add parameters
    create_cloudformation_template_parameter_code
 



    # Add Resources with proper handling for array types
    echo "Resources:" >> "$TEMPLATE_FILE_PATH"
    echo "  $RESOURCE_NAME:" >> "$TEMPLATE_FILE_PATH"
    echo "    Type: ${resource_type}" >> "$TEMPLATE_FILE_PATH"
    echo "    Properties:" >> "$TEMPLATE_FILE_PATH"
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

    # Add Outputs with full function names
    echo "Outputs:" >> "$TEMPLATE_FILE_PATH"
    echo "  ${RESOURCE_NAME}Id:" >> "$TEMPLATE_FILE_PATH"
    echo "    Description: The ID of the ${SERVICE_NAME} ${RESOURCE_NAME}" >> "$TEMPLATE_FILE_PATH"
    echo "    Value:" >> "$TEMPLATE_FILE_PATH"
    echo "      Ref: $RESOURCE_NAME" >> "$TEMPLATE_FILE_PATH"

    echo "CloudFormation template created and saved to $TEMPLATE_FILE_PATH"
}





