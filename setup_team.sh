#!/bin/bash
#
# Run this script to populate a Team ID.
# If you build with Xcode it will populate the file with Shopify's Team ID automatically

# get the location of this script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

TEAM_ID_CONFIG="$SCRIPT_DIR/Configurations/TeamID.xcconfig"

SHOPIFY_TEAM_ID=A7XGC83MZE
TEAM_ID="$1"

if [ "$TEAM_ID" = "default" ]; then
  TEAM_ID=$SHOPIFY_TEAM_ID
fi

if [ -z "$TEAM_ID" ]; then
  # no team id supplied, we'll prompt if the file doesn't exist
  if [ -f $TEAM_ID_CONFIG ]; then
    echo "$TEAM_ID_CONFIG already exists. Overwrite it? (y/n)"
    read ANS
    
    if [ "$ANS" == "y" ]; then
      rm $TEAM_ID_CONFIG
    else
      echo "$TEAM_ID_CONFIG already exists. Exiting."
      exit 1
    fi
  fi

  echo "What's your Apple Developer Team ID? (looks like: 1A2345BCDE). You can find this at https://developer.apple.com/account"
  read TEAM_ID

  if [ -z "$TEAM_ID" ]; then
    echo "You must enter a team ID"
    exit 1
  fi
fi


echo "DEVELOPMENT_TEAM = $TEAM_ID" > $TEAM_ID_CONFIG
