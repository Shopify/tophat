#!/bin/bash

TEAM_ID_CONFIG=Configurations/TeamID.xcconfig

if [ -f $TEAM_ID_CONFIG ]; then
  echo "$TEAM_ID_CONFIG already exists."
  exit 1
fi

echo "What's your Apple Developer Team ID? (looks like: 1A2345BCDE). You can find this at https://developer.apple.com/account"
read TEAM_ID

if [ -z "$TEAM_ID" ]; then
    echo "You must enter a team ID"
    exit 1
fi

echo "DEVELOPMENT_TEAM = $TEAM_ID" > $TEAM_ID_CONFIG
