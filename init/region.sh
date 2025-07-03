#!/bin/bash -e

#set the region
echo "get profile region"
REGION=$(get_region $ENV_PROFILE)
echo "The current region is $REGION. If you want to change the region enter it, otherwise enter."
read CHANGE_REGION
trim_spaces_and_quotes $CHANGE_REGION

is_valid_aws_region "$CHANGE_REGION" "$ENV_PROFILE"

if [ -n "$CHANGE_REGION" ]; then 
  echo "Changing $REGION to $CHANGE_REGION"
  REGION=$CHANGE_REGION; 
fi

