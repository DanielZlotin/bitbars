#!/bin/bash

# Prints BTC price, ETH price, proposed gas, BNB price

etherscanKey="***REMOVED***"

function parseJson() {
	json=$(cat)
	path="$1"
	python3 -c """import json; print(json.loads('$json')$path)"""
}

function fmt() {
	n="$1"
	python3 -c "print( f'{int(round($n,0)):,}' )"
}

gweiGas=$(fmt $(curl -s "https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=$etherscanKey" | parseJson "['result']['ProposeGasPrice']"))

priceETH=$(fmt $(curl -s "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD" | parseJson "['RAW']['ETH']['USD']['PRICE']"))
priceBTC=$(fmt $(curl -s "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD" | parseJson "['RAW']['BTC']['USD']['PRICE']"))
priceBNB=$(fmt $(curl -s "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BNB&tsyms=USD" | parseJson "['RAW']['BNB']['USD']['PRICE']"))

priceSP500=$(fmt $(curl -s "https://query1.finance.yahoo.com/v7/finance/quote?symbols=spy&fields=regularMarketPrice" | parseJson "['quoteResponse']['result'][0]['regularMarketPrice']"))

echo "💵${priceSP500}💰${priceBTC}💰${priceETH}⛽️${gweiGas}💰${priceBNB}"
echo "---"
echo "SP500: \$${priceSP500}"
echo "Bitcoin: \$${priceBTC}"
echo "Ethereum: \$${priceETH}"
echo "Gas: ${gweiGas} gwei"
echo "Binance: \$${priceBNB}"
