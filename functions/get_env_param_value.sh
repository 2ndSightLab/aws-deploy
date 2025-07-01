#!/bin/bash -e
get_env_param_value(){
  env_file_path="$1"
  param_name="$2"

  if [ -z "$env_file_path" ]; then echo "$env_file_path not set in get_env_param_value" >&2; exit 1; fi
  if [ -z "$param_name" ]; then echo "$param_name not set in get_env_param_value" >&2; exit 1; fi
  
  val=$(cat $env_file_path | grep $param_name | cut -d "=" -f2 | xargs)

  echo $val
}
