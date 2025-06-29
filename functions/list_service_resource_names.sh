list_service_resource_names() {
  SERVICE_NAME="$1"

  aws cloudformation list-types --visibility PUBLIC --type RESOURCE --filters Type=RESOURCE_TYPE_NAME,Value=AWS::${CF_SERVICE_NAME}::*

}
