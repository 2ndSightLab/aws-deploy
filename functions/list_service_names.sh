#!/bin/bash -e
list_service_resource_names() {
  SERVICE_NAME="$1"

  aws cloudformation list-types \
    --visibility PUBLIC \
    --type RESOURCE \
    --filters TypeNamePrefix=AWS::${SERVICE_NAME}:: \
    --query 'TypeSummaries[].TypeName' \
    --output text | sed "s/AWS::${SERVICE_NAME}:://g"
}
