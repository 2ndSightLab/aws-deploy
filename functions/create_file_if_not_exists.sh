#!/bin/bash -e
create_file_if_not_exists() {
    local file_path="$1"
    
    # Check if the file exists
    if [ ! -e "$file_path" ]; then
       mkdir -p "$(dirname "$file_path")"
       echo "File $file_path created."
    else
        echo "File $file_path already exists."
    fi
}
