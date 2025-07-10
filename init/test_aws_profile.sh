#!/bin/bash -e
if [ $DEBUG ]; then 
  echo "Testing profile: $ENV_PROFILE in region: $REGION"
  aws sts get-caller-identity --profile $ENV_PROFILE --region $REGION
fi
