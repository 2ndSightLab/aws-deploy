#!/bin/bash -e
create_stack_file() {

  validate_first_n_args_set 6 "$@"
    
  STACK_FILE_PATH="$1"
  STACK_RESOURCE_NAME="$2"
  RESOURCE_TYPE="$3"
  TEMPLATE_FILE_PATH="$4"
  SCRIPT_FILE_PATH="$5"
  PARAMETER_OVERRIDES_B64="$6"

  echo "storing the stack code generation info to: $STACK_FILE_PATH"
  timestamp=$(date +'%Y%m%d-%I:%M:%S%p')
  rm $STACK_FILE_NAME
  touch $STACK_FILE_NAME
  echo "$STACK_NAME:" > $STACK_FILE_NAME
  indent="  "
  echo $indent'CODE_CREATION_TIMESTAMP='$timestamp >> "$STACK_FILE_NAME"
  echo $indent'STACK_RESOURCE_NAME='$STACK_RESOURCE_NAME >> "$STACK_FILE_NAME"
  echo $indent'RESOURCE_TYPE='$RESOURCE_TYPE >> "$STACK_FILE_NAME"
  echo $indent'TEMPLATE_FILE_PATH='$TEMPLATE_FILE_PATH >> "$STACK_FILE_NAME"
  echo $indent'SCRIPT_FILE_PATH='$SCRIPT_FILE_PATH >> "$STACK_FILE_NAME"
  echo $indent'PARAMETER_OVERRIDES_B64='$PARAMETER_OVERRIDES_B64 >> "$STACK_FILE_NAME"

}
