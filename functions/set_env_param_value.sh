#!/bin/bash -ex
set_env_param_value() {

  validate_fist_n_args_set 3  "$@"

  env_file_path="$1"
  param_name="$2"
  value="$3"
    
  if [[ "$param_name" == *"|"* ]]; then
    echo "Error: The variable 'param_name' contains a pipe character '|', which is not allowed." >&2
    exit 1
  fi
  
  if [[ "$value" == *"|"* ]]; then
    echo "Error: The variable 'value' contains a pipe character '|', which is not allowed." >&2
    exit 1
  fi

  #set the parameter value
  sed -i "s|^${param_name}=.*|${param_name}=\"${value}\"|" "$env_file_path"

  if [ $? -ne 0 ]; then
     echo "Error: Failed to update parameter '$param_name' in file '$env_file_path'." >&2
     exit 1
  fi

}
