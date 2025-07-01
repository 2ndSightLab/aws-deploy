#!/bin/bash
get_env_param_value(){
  env_file_path="$1"
  param="$2"

  val=$(cat $env_file_path | grep $param | cut -d "=" -f2 | xargs)

  echo $val
}
