#!/bin/bash -e
create_stack_file() {

  validate_first_n_args_set 8 "$@"
  
  $RESOURCE_TYPE="$1"   
  $STACK_NAME="$2"
  $ENV_PROFILE="$3"
  $REGION="$4"
  $TEMPLATE_FILE_PATH="$5"
  $SCRIPT_FILE_PATH="$6"
  $IAM_CAPABILITY="$7"
  $PARAMETER_OVERRIDES_B64="$8"
         
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
