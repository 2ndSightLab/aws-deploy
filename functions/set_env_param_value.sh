#!/bin/bash -e
set_env_param_value(){
  env_file_path="$1"
  param_name="$2"
  value"$3"

  if [ -z "$env_file_path" ] || [ -z "$param_name" ] || [ -z "$value" ]; then
     echo "Error: env_file_path, param_name, and value must all be provided." >&2
     exit 1
  fi

  #set the parameter value
  sed -i "s/^${param_name}=.*/${param_name}=\"${value}\"/" "$env_file_path"

  # Check if the sed command was successful
  if [ $? -ne 0 ]; then
     echo "Error: Failed to update parameter '$param_name' in file '$env_file_path'." >&2
     exit 1
  fi

}
