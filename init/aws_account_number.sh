#!/bin/bash -e
if [ $DEBUG ]; then echo "Getting AWS Account number"; fi
ACCOUNT=$(get_aws_account $ENV_PROFILE)
if [ -z "$ACCOUNT" ]; then echo "Error: Account not set from profile $ENV_PROFILE"; exit; fi
if [ $DEBUG ]; then echo "AWS ACCOUNT NUMBER: $ACCOUNT"; fi


