#!/bin/bash

# Prints BTC price, eth price and FAST gas

API_TOKEN="***REMOVED***"

function parseJson() {
	json=$(cat)
	path="$1"
	python3 -c "print($json$path)"
}

function fmt() {
	n="$1"
	python3 -c "print( f'{int(round($n,0)):,}' )"
}

etherscanEthUrl="https://api.etherscan.io/api?module=stats&action=ethprice&apikey=$API_TOKEN"
etherscanGasUrl="https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=$API_TOKEN"

ethPrice=$(curl -s "$etherscanEthUrl" | parseJson "['result']['ethusd']")
gasPrice=$(curl -s "$etherscanGasUrl" | parseJson "['result']['FastGasPrice']")

wbtcEthPairAddress="0xbb2b8038a1640196fbe3e38816f3e67cba72d940"
wbtcAddress="0x2260fac5e5542a773aa44fbcfedf7c193bc2c599"
wethAddress="0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
btcPairBalance=$(curl -s "https://api.etherscan.io/api?module=account&action=tokenbalance&contractaddress=${wbtcAddress}&address=${wbtcEthPairAddress}&tag=latest&apikey=${API_TOKEN}" | parseJson "['result']")
ethPairBalance=$(curl -s "https://api.etherscan.io/api?module=account&action=tokenbalance&contractaddress=${wethAddress}&address=${wbtcEthPairAddress}&tag=latest&apikey=${API_TOKEN}" | parseJson "['result']")

btcPrice=$(python3 -c """
btcBalance = $btcPairBalance / float(10**8)
ethBalance = $ethPairBalance / float(10**18)
ethPerBtc = ethBalance / float(btcBalance)
print($ethPrice * ethPerBtc)
""")

ethRoundPrice=$(fmt "$ethPrice")
btcRoundPrice=$(fmt "$btcPrice")

echo "💰${btcRoundPrice}💰${ethRoundPrice}⛽️${gasPrice}"
