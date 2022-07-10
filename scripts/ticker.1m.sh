#!/bin/bash

# Prints SP500, BTC price, ETH price, proposed gas

. $(dirname "$0")/../.env

function parseJson() {
	json=$(cat)
	path="$1"
	python3 -c """import json; print(json.loads('$json')$path)"""
}

function fmt() {
	n="$1"
	python3 -c "print( f'{int(round($n,0)):,}' )"
}

gweiGas=$(fmt $(curl -s "https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=$ETHERSCAN_KEY" | parseJson "['result']['ProposeGasPrice']"))

result=$(curl -s "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH,BTC&tsyms=USD&api_key=${COINMARKETCAP_KEY}")
priceETH=$(fmt $(echo $result | parseJson "['RAW']['ETH']['USD']['PRICE']"))
priceBTC=$(fmt $(echo $result | parseJson "['RAW']['BTC']['USD']['PRICE']"))
# priceBTC=$(fmt $(curl -s "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD&api_key=${COINMARKETCAP_KEY}" | parseJson "['RAW']['BTC']['USD']['PRICE']"))

priceSP500=$(fmt $(curl -s "https://query1.finance.yahoo.com/v7/finance/quote?symbols=spy&fields=regularMarketPrice" | parseJson "['quoteResponse']['result'][0]['regularMarketPrice']"))

echo "💵${priceSP500}💰${priceBTC}💰${priceETH}⛽️${gweiGas}"
echo "---"
echo "SP500: \$${priceSP500}"
echo "Bitcoin: \$${priceBTC}"
echo "Ethereum: \$${priceETH}"
echo "Gas: ${gweiGas} gwei"
