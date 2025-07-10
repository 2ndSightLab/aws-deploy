#!/bin/bash -e
is_valid_aws_profile() {

    validate_first_n_args_set 1  "$@"
    
    local profile="$1"
    
    if [ $DEBUG ]; then
      echo "Checking to see if $profile is a valid AWS CLI profile on this system."
      echo "Profiles:"
      aws configure list-profiles
    fi

    if aws configure list-profiles | grep -q "^${profile}$"; then
       exists="y"
    fi
    
    if [ "$exists" == "y" ]; then return 0; else return 1; fi

}
