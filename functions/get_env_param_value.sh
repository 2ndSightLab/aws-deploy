#!/bin/bash -e
get_env_param_value(){
  env_file_path="$1"
  param_name="$2"

  if [ -z "$env_file_path" ]; then echo "$env_file_path not set in get_env_param_value" >&2; exit 1; fi
  if [ -z "$param_name" ]; then echo "$param_name not set in get_env_param_value" >&2; exit 1; fi

  if [ -f "$env_file_path" ]; then 
      echo ""; return 
  fi

  val=$(grep "$param_name:" "$env_file_path" | sed -e 's/^.*://' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  if [ $? -ne 0 ]; then
       echo "Error: Failed to get parameter '$param_name' in file '$env_file_path'." >&2
       exit 1
  fi
  
  echo $val
}
