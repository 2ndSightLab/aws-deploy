#!/bin/bash -e
create_deploy_script_for_resource() {

    validate_first_n_args_set 8 "$@"
    
    local ENV_PROFILE="$1"
    local REGION="$2"
    local RESOURCE_TYPE="$3"
    local SCRIPT_FILE_PATH="$4"
    local TEMPLATE_FILE_PATH="$5"
    local SCHEMA_B64="$6"
    local STACK_NAME="$7"
    local STACK_FILE_PATH="$8"

    echo '#!/bin/bash -e' > "$SCRIPT_FILE_PATH"
    chmod +x "$SCRIPT_FILE_PATH"

    #record the values used for this deployment to the stack file path
    s="#record deployment values in $STACK_FILE_PATH"; echo $s >> "$SCRIPT_FILE_PATH"
    s="echo \"ENV_PROFILE: $ENV_PROFILE\" > $STACK_FILE_PATH"; echo $s >> "$SCRIPT_FILE_PATH"
    s="echo \"REGION: $REGION\" >> $STACK_FILE_PATH"; echo $s >> "$SCRIPT_FILE_PATH"
    s="echo \"RESOURCE: $RESOURCE_TYPE\" >> $STACK_FILE_PATH"; echo $s >> "$SCRIPT_FILE_PATH"
    s="echo \"SCRIPT_FILE_PATH: $SCRIPT_FILE_PATH\" >> $STACK_FILE_PATH"; echo $s >> "$SCRIPT_FILE_PATH"
    s="echo \"TEMPLATE_FILE_PATH: $TEMPLATE_FILE_PATH\" >> $STACK_FILE_PATH"; echo $s >> "$SCRIPT_FILE_PATH"
    s="echo \"SCHEMA_B64: $SCHEMA_B64\" >> $STACK_FILE_PATH"; echo $s >> "$SCRIPT_FILE_PATH"
    s="echo \"STACK_NAME: $STACK_NAME\" >> $STACK_FILE_PATH"; echo $s >> "$SCRIPT_FILE_PATH"
    s="echo \"STACK_FILE_PATH: $STACK_FILE_PATH\">> $STACK_FILE_PATH"; echo $s >> "$SCRIPT_FILE_PATH"
    
    if [ $DEBUG ]; then echo "Generate proprety code"; fi
    create_deploy_script_resource_properties "$RESOURCE_TYPE" "$SCRIPT_FILE_PATH" "$TEMPLATE_FILE_PATH" "$SCHEMA_B64" "$IAM_CAPABILITY"
    
    if [ $DEBUG ]; then echo "Set IAM_CAPABILITY variable based on resource type"; fi
    echo "" >> "$SCRIPT_FILE_PATH"
    echo "# Set IAM capability flag based on resource type" >> "$SCRIPT_FILE_PATH"
    echo "IAM_CAPABILITY=false" >> "$SCRIPT_FILE_PATH"

    if [ $DEBUG ]; then echo "Check if resource type requires IAM permissions with more precise matching"; fi
    echo "# Check if resource requires IAM permissions" >> "$SCRIPT_FILE_PATH"
    echo "if [[ \"$RESOURCE_TYPE\" == \"AWS::IAM::\"* ]]; then" >> "$SCRIPT_FILE_PATH"
    echo "  IAM_CAPABILITY=true" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"This resource requires IAM capabilities for deployment.\"" >> "$SCRIPT_FILE_PATH"
    echo "fi" >> "$SCRIPT_FILE_PATH"

    echo "if [[ -z \"\$PARAMETER_OVERRIDES\" ]]; then" >> "$SCRIPT_FILE_PATH"
    echo "  read -p \"No parameters provided. Continue? (y/n): \" REPLY " >> "$SCRIPT_FILE_PATH"
    echo "  [[ ! \$REPLY =~ ^[Yy]$ ]] && exit 1" >> "$SCRIPT_FILE_PATH"

    local PARAMETER_OVERRIDES_B64=""
    
    echo "else" >> "$SCRIPT_FILE_PATH"
    echo "  # Add base64 encoding of parameter overrides with proper handling of special characters" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"\"" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"# Base64 encode the parameter overrides\"" >> "$SCRIPT_FILE_PATH"
    echo "  PARAMETER_OVERRIDES_B64=\$(echo -n \"\$PARAMETER_OVERRIDES\" | base64 -w 0)" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"\"" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"Base64 encoded parameters:\"" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"\$PARAMETER_OVERRIDES_B64\"" >> "$SCRIPT_FILE_PATH"
    echo "fi" >> "$SCRIPT_FILE_PATH"

    #add parameter ovrerrides to stack file
    s="#record parameter values in $STACK_FILE_PATH"; echo $s >> "$SCRIPT_FILE_PATH"
    s="echo PARAMETER_OVERRIDES_B64: \$PARAMETER_OVERRIDES_B64: >> $STACK_FILE_PATH"; echo $s >> "$SCRIPT_FILE_PATH"
     
    # Add template file existence check
    echo "# Check if CloudFormation template file exists" >> "$SCRIPT_FILE_PATH"
    echo "if [[ ! -f \"$TEMPLATE_FILE_PATH\" ]]; then" >> "$SCRIPT_FILE_PATH"
    echo "  echo \"Error: CloudFormation template file not found at $TEMPLATE_FILE_PATH\" >&2" >> "$SCRIPT_FILE_PATH"
    echo "  exit 1" >> "$SCRIPT_FILE_PATH"
    echo "fi" >> "$SCRIPT_FILE_PATH"
    echo "" >> "$SCRIPT_FILE_PATH"
    
    # Deploy CloudFormation stack
    echo "# Deploy CloudFormation stack" >> "$SCRIPT_FILE_PATH"
    echo "  deploy_cloudformation_stack \$STACK_NAME \$TEMPLATE_FILE_PATH \$ENV_PROFILE \$REGION \$IAM_CAPABILITY \$PARAMETER_OVERRIDES_B64" >> "$SCRIPT_FILE_PATH"
    echo "Created deployment script at $SCRIPT_FILE_PATH"
    
}

