#!/bin/bash

SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | awk -F: '/ SSID/{print $2}')

[ ! -z "${SSID// }" ] && echo "⏣$SSID"
