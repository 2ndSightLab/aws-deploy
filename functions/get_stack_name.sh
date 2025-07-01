get_stack_name() {
    local ENV_NAME="$1"
    local IDENTITY_NAME="$2"
    local SERVICE="$3"
    local RESOURCE="$4"
    local NAME="$5"

    if [ -z "$ENV_NAME" ]; then echo "$ENV_NAME not set in get_stack_name" >&2; exit 1; fi
    if [ -z "$IDENTITY_NAME" ]; then echo "$IDENTITY_NAME not set in get_stack_name" >&2; exit 1; fi
    if [ -z "$SERVICE" ]; then echo "$SERVICE not set in get_stack_name" >&2; exit 1; fi
    if [ -z "$RESOURCE" ]; then echo "$RESOURCE not set in get_stack_name" >&2; exit 1; fi
    if [ -z "$NAME" ]; then echo "$NAME not set in get_stack_name" >&2; exit 1; fi

    # Concatenate the string
    local FULL_NAME="${ENV_NAME}-${IDENTITY_NAME}-${SERVICE}-${RESOURCE}-${NAME}"

    # Convert to lowercase
    FULL_NAME=$(echo "$FULL_NAME" | tr '[:upper:]' '[:lower:]')

    # Remove any characters that don't match the pattern
    FULL_NAME=$(echo "$FULL_NAME" | sed -E 's/[^a-z0-9-]/-/g')

    # If the name starts with a number, prefix it with "a-"
    FULL_NAME=$(echo "$FULL_NAME" | sed -E 's/^([0-9])/a-\1/')

    # Remove any trailing hyphens
    FULL_NAME=$(echo "$FULL_NAME" | sed -E 's/-+$//g')

    # If the name is empty after processing, return an error
    if [ -z "$FULL_NAME" ]; then
        echo "Error: Invalid stack name after processing." >&2
        return 1
    fi

    # Return the processed string
    echo "$FULL_NAME"
}
