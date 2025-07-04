#/bin/bash -e
deploy_cloudformation_stack() {
  
    validate_first_n_args_set 4 "$@"
    
    local STACK_NAME="$1"
    local TEMPLATE_FILE_PATH="$2"
    local ENV_PROFILE="$3"
    local REGION="$4"
    local IAM=${5:-false}
    local ENCODED_PARAMETER_LIST=$6

    if [ $DEBUG ]; then 
      echo "ENCODED_PARAMETER_LIST: $ENCODED_PARAMETER_LIST"
    fi 
    
    # Check if the stack exists in a failed state
    if aws cloudformation describe-stacks --stack-name "$STACK_NAME" --profile $ENV_PROFILE --region $REGION 2>/dev/null | grep -q "CREATE_FAILED\|ROLLBACK_COMPLETE"; then
        echo "Stack $STACK_NAME exists in a failed state. Deleting..."
        aws cloudformation delete-stack --stack-name "$STACK_NAME" --profile $ENV_PROFILE --region $REGION
        aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" --profile $ENV_PROFILE --region $REGION
    fi

    # Prepare the deploy command
    local deploy_cmd="aws cloudformation deploy --stack-name $STACK_NAME --template-file $TEMPLATE_FILE_PATH --profile $ENV_PROFILE --region $REGION"

    # Handle parameter list if provided
    # Apparently all these formats are supported:
    # "InstanceType=t2.micro" "KeyName=my-key" "BucketName=my-bucket" "Description=This is a sample description with spaces" 
    # InstanceType=t2.micro KeyName=my-key BucketName=my-bucket "Description=This is a sample description with spaces" 
    # InstanceType=t2.micro KeyName=my-key BucketName=my-bucket Description="This is a sample description with spaces" 
    if [ "$ENCODED_PARAMETER_LIST" == "" ]; then
        if [ $DEBUG ]; then echo "No parameters in deploy_cloudformation_stack"; fi
    else 
        if [ $DEBUG ]; then echo "Decoding parameters"; fi
        local decoded_params=$(echo "$ENCODED_PARAMETER_LIST" | base64 --decode)
        if [ $DEBUG ]; then echo "Parameters: $decoded_parameters"; fi
        deploy_cmd+=" --parameter-overrides $decoded_params"
    fi

    # Add IAM capabilities if IAM is true
    if [ "$IAM" = true ]; then
        deploy_cmd+=" --capabilities CAPABILITY_NAMED_IAM"
    fi

    # Execute the deploy command
    echo "Deploying stack $STACK_NAME"
    echo "$deploy_cmd"
    $deploy_cmd
    
}
