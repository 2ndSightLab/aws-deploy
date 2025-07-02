#!/bin/bash -e
is_valid_aws_profile() {
     
    validate_first_n_args_set 1  "$@"
     
    local profile="$1"
    
    # if profile doesn't match an existing profile
    if aws configure list-profiles 2>/dev/null | grep -q "^${profile}$"; then

        if [ -n "$AWS_EXECUTION_ENV" ] && [ "$profile" == "default" ]; then

          #add default profile
          echo "[default]" >> ~/.aws/config
          echo "region = $REGION" >> ~/.aws/config
          echo "output = json" >> ~/.aws/config
          echo "credential_source = EcsContainer" >> ~/.aws/config
          
          if aws configure list-profiles 2>/dev/null | grep -q "^${profile}$"; then
             #profile exists
             return 0
          else
             return 1
          fi
        
        fi
        return 0
    else
        return 1
    fi
}
