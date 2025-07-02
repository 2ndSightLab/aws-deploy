#!/bin/bash -e
#call aws command with retry logic
run_aws_cmd_with_retry() {
    local cmd="$@"
    local max_attempts=5
    local attempt=0
    local wait_time=1

    while [ $attempt -lt $max_attempts ]; do
        output=$(eval $cmd 2>&1)
        if [[ $? -eq 0 ]]; then
            # Success
            echo "$output"
            return 0
        elif [[ "$output" == *"Throttling"* ]]; then
            # Throttling error occurred
            attempt=$((attempt + 1))
            
            if [ $attempt -eq $max_attempts ]; then
                echo "Error: Maximum retry attempts reached" >&2
                echo "$output" >&2
                return 1
            fi
            
            echo "Throttling detected. Retrying in $wait_time seconds... (Attempt $attempt of $max_attempts)" >&2
            sleep $wait_time
            wait_time=$((wait_time * 2))  # Simple exponential backoff
        else
            # Different error occurred
            echo "$output" >&2
            return 1
        fi
    done
}
