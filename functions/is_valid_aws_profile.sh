#!/bin/bash -e
is_valid_aws_profile() {

    local profile="$1"
    
    if [ $DEBUG ]; then
      echo "Checking to see if $profile is a valid AWS CLI profile on this system."
    fi

    if aws configure list-profiles | grep -q "^${profile}$"; then
       echo "Default profile added for CloudShell"
       exists="y"
    fi
    
    if [ "$exists" == "y" ]; then return 0; else return 1; fi

}
