#!/bin/bash -e
get_env_param_value(){

  validate_first_n_args_set 2  "$@"
  
  env_file_path="$1"
  param_name="$2"

  param_name=$(trim_spaces_and_quotes $param_name)
  
  if [ ! -f "$env_file_path" ]; then echo ""; return; fi

  val=$(grep "^${param_name}=" "$env_file_path" | cut -d "=" -f2)
  val=$(trim_spaces_and_quotes $val)
  
  if [ $? -ne 0 ]; then
       echo "Error: Failed to get parameter '$param_name' in file '$env_file_path'." >&2
       exit 1
  fi
  
  echo $val
}
