#!/bin/bash -e
create_cloudformation_template() {

    validate_first_n_args_set 6  "$@"

    local RESOURCE_NAME=$1
    local RESOURCE_TYPE=$2
    local TEMPLATE_FILE_PATH=$3
    local ENV_PROFILE=$4
    local REGION=$5
    local SCHEMA_B64=$6
    
    echo "AWSTemplateFormatVersion: '2010-09-09'" > "$TEMPLATE_FILE_PATH"
    echo "Description: CloudFormation template for $RESOURCE_TYPE" >> "$TEMPLATE_FILE_PATH"
    echo "" >> "$TEMPLATE_FILE_PATH"

    echo "Parameters:" >> "$TEMPLATE_FILE_PATH"
    create_cloudformation_template_parameter_code $RESOURCE_TYPE $TEMPLATE_FILE_PATH $SCHEMA_B64
    
    echo "Conditions:" >> "$TEMPLATE_FILE_PATH"
    create_cloudformation_template_condition_code $RESOURCE_TYPE $TEMPLATE_FILE_PATH $SCHEMA_B64
    
    echo "Resources:" >> "$TEMPLATE_FILE_PATH"
    echo "  $RESOURCE_NAME:" >> "$TEMPLATE_FILE_PATH"
    echo "    Type: ${RESOURCE_TYPE}" >> "$TEMPLATE_FILE_PATH"
    echo "    Properties:" >> "$TEMPLATE_FILE_PATH"
    create_cloudformation_template_resource_code $RESOURCE_TYPE $TEMPLATE_FILE_PATH $SCHEMA_B64
    
    echo "Create CloudFormation template outputs code"
   
    echo "Outputs:" >> "$TEMPLATE_FILE_PATH"
    echo "  ${RESOURCE_NAME}Id:" >> "$TEMPLATE_FILE_PATH"
    echo "    Description: The ID of the ${RESOURCE_TYPE}" >> "$TEMPLATE_FILE_PATH"
    echo "    Value:" >> "$TEMPLATE_FILE_PATH"
    echo "      Ref: $RESOURCE_NAME" >> "$TEMPLATE_FILE_PATH"

    echo "CloudFormation template created and saved to $TEMPLATE_FILE_PATH"
}





