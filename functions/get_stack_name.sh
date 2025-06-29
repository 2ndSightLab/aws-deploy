#!/bin/bash -e
get_stack_name() {
    local ENV_NAME="$1"
    local IDENTITY_NAME="$2"
    local SERVICE="$3"
    local RESOURCE="$4"
    local NAME="$5"

    # Check if all parameters are provided
    if [ -z "$ENV_NAME" ] || [ -z "$IDENTITY_NAME" ] || [ -z "$SERVICE" ] || [ -z "$RESOURCE" ] ; then
        echo "Error: All parameters (ENV_NAME, USERNAME, SERVICE, RESOURCE) must be provided." >&2
        exit
    fi

    # Return the concatenated string
    echo "$ENV_NAME-$IDENTITY_NAME-$SERVICE-$RESOURCE-$NAME" | tr '[:upper:]' '[:lower:]'
}
