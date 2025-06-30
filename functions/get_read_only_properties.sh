#!/bin/bash
get_read_only_properties(){
   SCHEMA="$1"
   readOnlyProps=$(jq -r 'if type == "string" then fromjson else . end | if has("readOnlyProperties") then .readOnlyProperties[] else empty end' <<< "$SCHEMA" | sed 's|/properties/||g')
   echo $readOnlyProps  
}
