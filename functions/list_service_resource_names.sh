list_service_resource_names() {
  SERVICE_NAME="$1"
  ENV_PROFILE="$2"
  REGION="$3"
  
  if [ -z "$SERVICE_NAME" ]; then echo "$SERVICE_NAME not set in list_service_resource_names" >&2; exit 1; fi
  if [ -z "$ENV_PROFILE" ]; then echo "$ENV_PROFILE not set in list_service_resource_names" >&2; exit 1; fi 
  if [ -z "$REGION" ]; then echo "$REGION not set in list_service_resource_names" >&2; exit 1; fi

  aws cloudformation list-types \
    --visibility PUBLIC \
    --type RESOURCE \
    --filters TypeNamePrefix=AWS::${SERVICE_NAME}:: \
    --query 'TypeSummaries[].TypeName' \
    --output text | sed "s/AWS::${SERVICE_NAME}:://g"
}
