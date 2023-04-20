#!/bin/bash

# Prints SP500, BTC price, ETH price, gas, time in LA NY UTC

function parseJson() {
	json=$(cat)
	path="$1"
	python3 -c """import json; print(json.loads('$json')$path)"""
}

function fmt() {
	n="$1"
	python3 -c "print( f'{int(round($n,0)):,}' )"
}

result=$(curl -s "https://query1.finance.yahoo.com/v6/finance/quote?symbols=spy,btc-usd,eth-usd&fields=regularMarketPrice")

priceSP500=$(fmt $(echo $result | parseJson "['quoteResponse']['result'][0]['regularMarketPrice']"))
priceBTC=$(fmt $(echo $result | parseJson "['quoteResponse']['result'][1]['regularMarketPrice']"))
priceETH=$(fmt $(echo $result | parseJson "['quoteResponse']['result'][2]['regularMarketPrice']"))
gasGwei=$(fmt $(curl -s "https://api.blocknative.com/gasprices/blockprices" | parseJson "['maxPrice']"))

time="⌚LA:$(TZ=America/Los_Angeles date +'%H') NY:$(TZ=America/New_York date +'%H') UTC:$(TZ=UTC date +'%H')"

echo "💵${priceSP500}💰${priceBTC}💰${priceETH}⛽️${gasGwei}"
echo "---"
echo "SP500: \$${priceSP500}"
echo "Bitcoin: \$${priceBTC}"
echo "Ethereum: \$${priceETH}"
echo "Gas: ${gasGwei} gwei"
echo "$time"
