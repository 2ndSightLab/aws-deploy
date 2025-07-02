#!/bin/bash -e

IDENTITY_ARN=$(get_current_identity_arn $ENV_PROFILE $REGION)
IDENTITY_NAME=$(get_identity_name_from_arn $IDENTITY_ARN $ENV_PROFILE $REGION)
