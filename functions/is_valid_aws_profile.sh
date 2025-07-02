#!/bin/bash -e
is_valid_aws_profile() {

    local profile="$1"
    local REGION="$2"

    exists="n"
    if aws configure list-profiles | grep -q "^${profile}$"; then
        exists="y"
    else

        if [ -n "$AWS_EXECUTION_ENV" ] && [ "$profile" == "default" ];  then

          echo "AWS CloudShell environment" >&2

          #add default profile
          echo "[default]" >> ~/.aws/config
          echo "region = $REGION" >> ~/.aws/config
          echo "output = json" >> ~/.aws/config
          echo "credential_source = EcsContainer" >> ~/.aws/config

          if aws configure list-profiles | grep -q "^${profile}$"; then
             echo "Default profile added for CloudShell"
             exists="y"
          fi
       fi
    fi

    if [ "$exists" == "y" ]; then return 0; else return 1; fi

}
