#!/bin/bash
get_identity_name_from_arn() {
    local arn=$1
    
    # Check if ARN is provided
    if [ -z "$arn" ]; then
        echo "Error: ARN must be provided." >&2
        return 1
    fi
    
    # Split the ARN into parts
    local arn_parts=(${arn//:/ })
    
    # Get the resource type and name
    local resource_path=${arn_parts[5]}
    
    # Debug output to see what's happening
    # echo "DEBUG: ARN=$arn" >&2
    # echo "DEBUG: resource_path=$resource_path" >&2
    
    # Handle different ARN formats
    case $resource_path in
        "root")
            echo "root"
            ;;
        user*)
            # For IAM users: arn:aws:iam::123456789012:user/username
            # Remove quotes around pattern to match more broadly
            local username=${resource_path#user/}
            echo "$username"
            ;;
        role*)
            # For IAM roles: arn:aws:iam::123456789012:role/rolename
            local rolename=${resource_path#role/}
            echo "$rolename"
            ;;
        "assumed-role"*)
            # For assumed roles: arn:aws:sts::123456789012:assumed-role/rolename/sessionname
            local role_session=${resource_path#assumed-role/}
            local rolename=${role_session%%/*}
            echo "$rolename"
            ;;
        "federated-user"*)
            # For federated users: arn:aws:sts::123456789012:federated-user/username
            local username=${resource_path#federated-user/}
            echo "$username"
            ;;
        *)
            # If all else fails, try to extract a username from the last part of the ARN
            if [[ "$arn" == *:user/* ]]; then
                local username=${arn##*:user/}
                echo "$username"
            else
                echo "Error: Cloud not get user name from: $arn. Resource_path: $resource_path" >&2
                return 1
            fi
            ;;
    esac
}
