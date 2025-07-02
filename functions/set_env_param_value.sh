#!/bin/bash
set_env_param_value(){
  env_file_path="$1"
  param_name="$2"
  value="$3"

  if [ -z "$env_file_path" ]; then echo "$env_file_path not set in set_env_param_value" >&2; exit 1; fi 
  if [ -z "$param_name" ]; then echo "$param_name not set in set_env_param_value" >&2; exit 1; fi
  if [ -z "$value" ]; then echo "$value not set in set_env_param_value" >&2; exit 1; fi 
  if [[ "$param_name" == *"|"* ]] && { echo "Error: The variable 'param_name' contains a pipe character '|', which is not allowed." >&2; exit 1; }  
  if [[ "$value" == *"|"* ]] && { echo "Error: The variable 'value' contains a pipe character '|', which is not allowed." >&2; exit 1; }

  #set the parameter value
  sed -i "s|^${param_name}=.*|${param_name}=\"${value}\"|" "$env_file_path"

  if [ $? -ne 0 ]; then
     echo "Error: Failed to update parameter '$param_name' in file '$env_file_path'." >&2
     exit 1
  fi

}
