#!/bin/bash -e
get_env_param_value(){
  env_file_path="$1"
  param_name="$2"

  if [ "$env_file_path" == "" ] || [ "$param_name" == "" ]; then
     echo "Error: env_file_path and param_name must be set." >&2
     exit 1
  fi
  
  val=$(cat $env_file_path | grep $param_name | cut -d "=" -f2 | xargs)

  echo $val
}
