#!/bin/bash -e
set_env_param_value() {

  validate_fist_n_args_set 3  "$@"

  env_file_path="$1"
  param_name="$2"
  value="$3"

  value=$(trim_spaces_and_quotes $value)
  param_name=$(trim_spaces_and_quotes $param_name)
  
  echo "Set $param_name: $value in $env_file_path"
    
  if [[ "$param_name" == *"|"* ]]; then
    echo "Error: The variable 'param_name' contains a pipe character '|', which is not allowed." >&2
    exit 1
  fi
  
  if [[ "$value" == *"|"* ]]; then
    echo "Error: The variable 'value' contains a pipe character '|', which is not allowed." >&2
    exit 1
  fi

  if ! grep -q "^${param_name}=" "$env_file_path"; then 
    #doesn't exist, add
    echo "${param_name}=\"${value}\"" >> "$env_file_path"
  else  
    #update
    sed -i "s|^${param_name}=.*|${param_name}=${value}|" "$env_file_path"
  fi

  if [ $? -ne 0 ]; then
     echo "Error: Failed to update parameter '$param_name' in file '$env_file_path'." >&2
     exit 1
  fi

}
