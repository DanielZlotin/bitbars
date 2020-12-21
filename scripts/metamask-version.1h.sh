#!/bin/bash -e

# Checks metamask version and alerts if changed

STATUS=1

hardcodedKnownVersion="8.1.9"
persistDomain="org.defi.metamaskversion"
persistKey="MetaMaskVersion"

chromeDir="$HOME/Library/Application Support/Google/Chrome"
extensionsDir="Extensions"
metamaskId="nkbihfbeogaeaoehlefnkodbefgpgknn"

function writeVersion() {
	version="$1"
	defaults write "$persistDomain" "$persistKey" "$version"
}

function readVersion() {
	echo $(defaults read "$persistDomain" "$persistKey" 2>/dev/null || echo "$hardcodedKnownVersion")
}

function getMetamaskVersionForUser() {
	userName="$1"
	metamaskDir="$chromeDir/$userName/$extensionsDir/$metamaskId"
	lastDir=$(ls "$metamaskDir" | tail -1)
	manifest="$metamaskDir/$lastDir/manifest.json"

	version=$(python -c """import json; print json.load(open('$manifest'))['version']""")
	echo "$version"
}

function alertMetamaskUpdated() {
	stableBtn="Mark Stable"
	snoozeBtn="Snooze"
	buttonPressed=$(osascript -e "display alert \"Warning! MetaMask was updated!\" message \"last known version: $lastKnownVersion\n new version: $detectedVersion\" buttons {\"$stableBtn\",\"$snoozeBtn\"}")
	if [[ "$buttonPressed" == "button returned:$stableBtn" ]]; then
		writeVersion "$detectedVersion"
		STATUS=1
	fi
}


lastKnownVersion=$(readVersion)
detectedVersion=$(getMetamaskVersionForUser "Default")

if [ "$detectedVersion" != "$lastKnownVersion" ]; then
	STATUS=0
	alertMetamaskUpdated
fi

[ $STATUS == 1 ] && echo "🟢" || echo "🔴"
echo "---"
echo "MetaMask version: $detectedVersion | color=white"
