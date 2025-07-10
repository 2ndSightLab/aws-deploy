list_service_resource_names() {

  validate_first_n_args_set 3  "$@"
  
  SERVICE_NAME="$1"
  ENV_PROFILE="$2"
  REGION="$3"
  
  cmd="aws cloudformation list-types \
    --visibility PUBLIC \
    --type RESOURCE \
    --filters TypeNamePrefix=AWS::${SERVICE_NAME}:: \
    --query 'TypeSummaries[].TypeName' \
    --output text | sed \"s/AWS::${SERVICE_NAME}:://g\""
    
  run_aws_cmd_with_retry $cmd
  
}
