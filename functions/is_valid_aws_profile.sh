#!/bin/bash -e
is_valid_aws_profile() {

    local profile="$1"
    
    if [ $DEBUG ]; then
      echo "Checking to see if $profile is a valid AWS CLI profile on this system."
    fi
    
    if [ -n "$AWS_EXECUTION_ENV" ] && [ "$profile" == "default" ];  then

          if [ $DEBUG ]; then
            echo "AWS CloudShell environment" >&2
          fi
          
          REGION=$(aws configure get region)
      
          #add default profile
          if [ ! -f $HOME/.aws/ ]; then 
              echo "Create $HOME/.aws/" >&2
              mkdir -p $HOME/.aws/
          fi
          
          echo "[default]" >> ~/.aws/config
          echo "region = $REGION" >> ~/.aws/config
          echo "output = json" >> ~/.aws/config
          echo "credential_source = EcsContainer" >> ~/.aws/config
       
    fi

    if aws configure list-profiles | grep -q "^${profile}$"; then
       echo "Default profile added for CloudShell"
       exists="y"
    fi
    
    if [ "$exists" == "y" ]; then return 0; else return 1; fi

}
