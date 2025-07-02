#!/bin/bash -e
validate_first_n_args_set() {
  local num_args_to_check="$1"
  local calling_func_name="${FUNCNAME[1]}"  # Get the name of the calling function [1]

  if [[ $# -lt "$num_args_to_check" ]]; then
    echo "Error in function '${calling_func_name}': Requires at least ${num_args_to_check} arguments." >&2
    exit 1
  fi

  for ((i = 1; i <= num_args_to_check; i++)); do
    local arg_value="${!i}" # Indirect parameter expansion
    if [[ -z ${!i+set} ]]; then
      echo "Error in function '${calling_func_name}': Argument ${i} is not set." >&2
      exit 1
    fi
  done
}
