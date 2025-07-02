#!/bin/bash -e
echo "Getting AWS Account number"
ACCOUNT=$(get_aws_account $ENV_PROFILE)
if [ -z "$ACCOUNT" ]; then echo "Error: Account not set from profile $ENV_PROFILE"; exit; fi
echo "AWS ACCOUNT NUMBER: $ACCOUNT"
