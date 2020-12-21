#!/bin/bash

# Prints eth price and gas

API_TOKEN="***REMOVED***"
etherscanEthUrl="https://api.etherscan.io/api?module=stats&action=ethprice&apikey=$API_TOKEN"
etherscanGasUrl="https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=$API_TOKEN"

function parseJson() {
	json=$(cat)
	path="$1"
	python3 -c "print($json$path)"
}

ethPrice=$(curl -s "$etherscanEthUrl" | parseJson "['result']['ethusd']")
gasPrice=$(curl -s "$etherscanGasUrl" | parseJson "['result']['ProposeGasPrice']")

echo "Ξ\$${ethPrice}⛽️${gasPrice}Ξ"
