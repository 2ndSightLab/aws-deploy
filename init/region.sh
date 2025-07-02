#set the region
echo "get profile region"
REGION=$(get_region $ENV_PROFILE)
echo "The current region is $REGION. If you want to change the region enter it now"
read CHANGE_REGION
if [ "$CHANGE_REGION" != "" ]; then REGION=$CHANGE_REGION; fi

echo "testing profile"
aws sts get-caller-identity --profile $ENV_PROFILE --region $REGION
