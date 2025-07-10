#!/bin/bash -e

echo "Get service resource type"
RESOURCE_TYPE="AWS::$SERVICE_NAME::$RESOURCE_NAME"
echo "RESOURCE_TYPE: $RESOURCE_TYPE"

echo "get the schema"
SCHEMA=$(get_resource_schema $RESOURCE_TYPE $ENV_PROFILE $REGION)
if [ -z "$SCHEMA" ]; then echo "Error: No schmea returned for resource type: $RESOURCE_TYPE"; exit 1; fi

#this will not work on a Mac. This code is designed to run on Amazon Linux
SCHEMA_B64=$(echo $SCHEMA | base64 -w 0)
validate_base64 $SCHEMA_B64

#echo "SCHEMA:"
#echo "$SCHEMA" | jq .

# for troubleshooting

#echo "Base64 encoded:"
#echo "$SCHEMA_B64"

#echo "Base64 decoded:"
#echo $SCHEMA_B64 | base64 -d 

#echo "base64 decoded pretty:"
#echo $SCHEMA_B64 | base64 -d | jq .

#could also check lenghth of original and output schema
