#!/bin/bash -e

local RESOURCE_TYPE="AWS::$SERVICE_NAME::$RESOURCE_NAME"
local SCHEMA=$(get_resource_schema $RESOURCE_TYPE $ENV_PROFILE $REGION)
local SCHEMA_B64=$(echo "$SCHEMA" | base64)
