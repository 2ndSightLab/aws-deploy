#!/bin/bash -e

echo "generating stack name"

prompt_name="
If the resource is a user, for a specific user, or associated with an application enter the name. Enter if n/a:
"
read -p "$prompt_name" NAME

STACK_NAME=$(get_stack_name "$ENV_NAME" "$IDENTITY_NAME" "$SERVICE_NAME" "$RESOURCE_NAME" "$NAME")
