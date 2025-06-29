#!/bin/bash
list_service_names(){
  aws cloudformation list-types --visibility PUBLIC --type RESOURCE --output json | jq -r '.TypeSummaries[].TypeName' | grep -o 'AWS::[^:]*' | sed 's/AWS:://' | sort -u
}
