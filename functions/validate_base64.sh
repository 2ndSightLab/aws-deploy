validate_base64() {
    local original="$1"
    
    local no_spaces=$(echo "$original" | tr -d '[:space:]')
    
    # Check if whitespace was removed
    if [ "$original" != "$no_spaces" ]; then
        echo "Error: Base64 string contains whitespace" >&2
        exit
    fi
}
