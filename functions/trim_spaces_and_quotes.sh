#!/bin/bash -e
trim_spaces_and_quotes(){

   value="$1"
   
   value=$(echo "$value" | sed -e "s|^[[:space:]\'\"]*||" -e "s|[[:space:]\'\"]*$||")

   echo $value

}
