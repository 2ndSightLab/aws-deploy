#/bin/bash -e
deploy_cloudformation_stack() {
    local STACK_NAME=$1
    local TEMPLATE_FILE_PATH=$2
    local ENCODED_PARAMETER_LIST=$3
    local IAM=${4:-false}

    # Check if the stack exists in a failed state
    if aws cloudformation describe-stacks --stack-name "$STACK_NAME" 2>/dev/null | grep -q "CREATE_FAILED\|ROLLBACK_COMPLETE"; then
        echo "Stack $STACK_NAME exists in a failed state. Deleting..."
        aws cloudformation delete-stack --stack-name "$STACK_NAME"
        aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME"
    fi

    # Prepare the deploy command
    local deploy_cmd="aws cloudformation deploy --stack-name $STACK_NAME --template-file $TEMPLATE_FILE_PATH"

    # Handle parameter list if provided
    # Apparently all these formats are supported:
    # "InstanceType=t2.micro" "KeyName=my-key" "BucketName=my-bucket" "Description=This is a sample description with spaces" 
    # InstanceType=t2.micro KeyName=my-key BucketName=my-bucket "Description=This is a sample description with spaces" 
    # InstanceType=t2.micro KeyName=my-key BucketName=my-bucket Description="This is a sample description with spaces" 
    if [ -n "$ENCODED_PARAMETER_LIST" ]; then
        local decoded_params=$(echo "$ENCODED_PARAMETER_LIST" | base64 --decode)
        echo "Parameters: $decoded_parameters"
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
