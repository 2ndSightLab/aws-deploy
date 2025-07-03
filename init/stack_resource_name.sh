#!/bin/bash -e
if [ $DEBUG ]; then
  echo "Generating STACK_RESOURCE_NAME"
fi 
STACK_RESOURCE_NAME=$(get_stack_resource_name "$ENV_NAME" "$SERVICE_NAME" "$RESOURCE_NAME" "$REGION" "$NAME")
if [ $DEBUG ]; then
  echo "STACK_RESOURCE_NAME: $STACK_RESOURCE_NAME"
fi
