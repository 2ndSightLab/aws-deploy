#!/bin/bash
create_cloudformation_template() {
    local SERVICE_NAME="$1"
    local RESOURCE_NAME="$2"
    local TEMPLATE_FILE_PATH=$(get_template_file_path $SERVICE_NAME $RESOURCE_NAME)

    # Construct the resource type directly
    resource_type="AWS::$SERVICE_NAME::$RESOURCE_NAME"

    # Extract properties from the Schema, including minLength
    schema=$(aws cloudformation describe-type --type RESOURCE --type-name "$resource_type" | jq -r '.Schema')
    properties_info=$(echo "$schema" | jq -r '.properties | to_entries[] | "\(.key):\(.value.type // "String"):\(.value.required // false):\(.value.minLength // 0)"' || echo "$schema" | jq -r 'fromjson | .properties | to_entries[] | "\(.key):\(.value.type // "String"):\(.value.required // false):\(.value.minLength // 0)"')

    # Start the template
    echo "AWSTemplateFormatVersion: '2010-09-09'" > "$TEMPLATE_FILE_PATH"
    echo "Description: CloudFormation template for $SERVICE_NAME $RESOURCE_NAME" >> "$TEMPLATE_FILE_PATH"
    echo "" >> "$TEMPLATE_FILE_PATH"

    # Add Parameters
    echo "Parameters:" >> "$TEMPLATE_FILE_PATH"
    for prop_info in $properties_info; do
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





