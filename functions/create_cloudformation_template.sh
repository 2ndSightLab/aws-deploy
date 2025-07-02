#!/bin/bash
create_cloudformation_template() {

    validate_first_n_args_set 4
    
    local SERVICE_NAME="$1"
    local RESOURCE_NAME="$2"
    local ENV_PROFILE="$3"
    local REGION="$4"
    
    local TEMPLATE_FILE_PATH=$(get_template_file_path $SERVICE_NAME $RESOURCE_NAME)
    local resource_type="AWS::$SERVICE_NAME::$RESOURCE_NAME"
    local SCHEMA=$(get_resource_schema $resource_type $ENV_PROFILE $REGION)
    local SCHEMA_B64=$(echo "$SCHEMA" | base64)
    
    # Start the template
    echo "AWSTemplateFormatVersion: '2010-09-09'" > "$TEMPLATE_FILE_PATH"
    echo "Description: CloudFormation template for $SERVICE_NAME $RESOURCE_NAME" >> "$TEMPLATE_FILE_PATH"
    echo "" >> "$TEMPLATE_FILE_PATH"

    echo "Parameters:" >> "$TEMPLATE_FILE_PATH"
    create_cloudformation_template_parameter_code "$RESOURCE_TYPE" "$SCHEMA_B64" "$TEMPLATE_FILE_PATH"
    
    echo "Conditions:" >> "$TEMPLATE_FILE_PATH"
    create_cloudformation_template_condition_code  "$RESOURCE_TYPE" "$SCHEMA_B64" "$TEMPLATE_FILE_PATH"

    echo "Resources:" >> "$TEMPLATE_FILE_PATH"
    echo "  $RESOURCE_NAME:" >> "$TEMPLATE_FILE_PATH"
    echo "    Type: ${resource_type}" >> "$TEMPLATE_FILE_PATH"
    echo "    Properties:" >> "$TEMPLATE_FILE_PATH"
    create_cloudformation_template_resource_code  "$RESOURCE_TYPE" "$SCHEMA_B64" "$TEMPLATE_FILE_PATH"

    echo "Outputs:" >> "$TEMPLATE_FILE_PATH"
    echo "  ${RESOURCE_NAME}Id:" >> "$TEMPLATE_FILE_PATH"
    echo "    Description: The ID of the ${SERVICE_NAME} ${RESOURCE_NAME}" >> "$TEMPLATE_FILE_PATH"
    echo "    Value:" >> "$TEMPLATE_FILE_PATH"
    echo "      Ref: $RESOURCE_NAME" >> "$TEMPLATE_FILE_PATH"

    echo "CloudFormation template created and saved to $TEMPLATE_FILE_PATH"
}





