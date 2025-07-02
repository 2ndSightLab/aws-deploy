#!/bin/bash -e
ACCOUNT=$(get_aws_account $ENV_PROFILE $REGION)
if [ -z "$ACCOUNT" ]; then echo "Error: Account not set from profile $ENV_PROFILE"; exit; fi
