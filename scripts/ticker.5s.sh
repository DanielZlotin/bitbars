#!/bin/bash

# Prints BTC price, eth price and FAST gas, BNB price

etherscanKey="***REMOVED***"
bscscanKey="***REMOVED***"

function parseJson() {
	json=$(cat)
	path="$1"
	python3 -c """import json; print(json.loads('$json')$path)"""
}

function fmt() {
	n="$1"
	python3 -c "print( f'{int(round($n,0)):,}' )"
}

etherscanEthUrl="https://api.etherscan.io/api?module=stats&action=ethprice&apikey=$etherscanKey"
etherscanGasUrl="https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=$etherscanKey"

ethPrice=$(curl -s "$etherscanEthUrl" | parseJson "['result']['ethusd']")
gasPrice=$(curl -s "$etherscanGasUrl" | parseJson "['result']['ProposeGasPrice']")

wbtcEthPairAddress="0xbb2b8038a1640196fbe3e38816f3e67cba72d940"
wbtcAddress="0x2260fac5e5542a773aa44fbcfedf7c193bc2c599"
wethAddress="0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
btcPairBalance=$(curl -s "https://api.etherscan.io/api?module=account&action=tokenbalance&contractaddress=${wbtcAddress}&address=${wbtcEthPairAddress}&tag=latest&apikey=${etherscanKey}" | parseJson "['result']")
ethPairBalance=$(curl -s "https://api.etherscan.io/api?module=account&action=tokenbalance&contractaddress=${wethAddress}&address=${wbtcEthPairAddress}&tag=latest&apikey=${etherscanKey}" | parseJson "['result']")

btcPrice=$(python3 -c """
btcBalance = $btcPairBalance / float(10**8)
ethBalance = $ethPairBalance / float(10**18)
ethPerBtc = ethBalance / float(btcBalance)
print($ethPrice * ethPerBtc)
""")

bnbUsdPairAddress="0x1b96b92314c44b159149f7e0303511fb2fc4774f"
busdAddress="0xe9e7cea3dedca5984780bafc599bd69add087d56"
wbnbAddress="0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c"
wbnbPairBalance=$(curl -s "https://api.bscscan.com/api?module=account&action=tokenbalance&contractaddress=${wbnbAddress}&address=${bnbUsdPairAddress}&tag=latest&apikey=$bscscanKey" | parseJson "['result']")
busdPairBalance=$(curl -s "https://api.bscscan.com/api?module=account&action=tokenbalance&contractaddress=${busdAddress}&address=${bnbUsdPairAddress}&tag=latest&apikey=$bscscanKey" | parseJson "['result']")
bnbPrice=$(python3 -c """
bnbBalance = $wbnbPairBalance / float(10**18)
busdBalance = $busdPairBalance / float(10**18)
print(busdBalance / float(bnbBalance))
""")

sp500Price=$(curl -s "https://query1.finance.yahoo.com/v7/finance/quote?symbols=spy&fields=regularMarketPrice" | parseJson "['quoteResponse']['result'][0]['regularMarketPrice']")

ethRoundPrice=$(fmt "$ethPrice")
btcRoundPrice=$(fmt "$btcPrice")
bnbRoundPrice=$(fmt "$bnbPrice")
sp500RoundPrice=$(fmt "$sp500Price")

echo "💵${sp500RoundPrice}💰${btcRoundPrice}💰${ethRoundPrice}⛽️${gasPrice}💰${bnbRoundPrice}"
echo "---"
echo "SP500: \$${sp500Price}"
echo "Bitcoin: \$${btcPrice}"
echo "Ethereum: \$${ethPrice}"
echo "Gas: ${gasPrice} gwei"
echo "Binance: \$${bnbPrice}"
