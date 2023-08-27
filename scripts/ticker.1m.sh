#!/bin/zsh

# Prints SP500, BTC price, ETH price, gas, time in LA NY UTC

p3=$(which python3)

function parseJson() {
	json=$(cat)
	path="$1"
	$p3 -c """import json; print(json.loads('$json')$path)"""
}

function fmt() {
	n="$1"
	decimals="$2"
	$p3 -c "print( f'{int(round(float($n) / (10 ** int($decimals)) )):,}' )"
}

time="⌚LA:$(TZ=America/Los_Angeles date +'%H') NY:$(TZ=America/New_York date +'%H') UTC:$(TZ=UTC date +'%H')"

gasresponse=$(curl -s "https://api.blocknative.com/gasprices/blockprices")

btcResponse=$(curl -s 'https://atlas-postgraphile.public.main.prod.cldev.sh/graphql' \
-H 'authority: atlas-postgraphile.public.main.prod.cldev.sh' \
-H 'accept: */*' \
-H 'accept-language: en-US,en;q=0.9,he;q=0.8' \
-H 'content-type: application/json' \
-H 'dnt: 1' \
-H 'origin: https://data.chain.link' \
-H 'referer: https://data.chain.link/' \
-H 'sec-ch-ua: "Google Chrome";v="113", "Chromium";v="113", "Not-A.Brand";v="24"' \
-H 'sec-ch-ua-mobile: ?0' \
-H 'sec-ch-ua-platform: "macOS"' \
-H 'sec-fetch-dest: empty' \
-H 'sec-fetch-mode: cors' \
-H 'sec-fetch-site: cross-site' \
-H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36' \
--data-raw $'{"query":"\\nquery PriceHistoryQuery($schemaName: String\u0021, $contractAddress: String\u0021) {\\n  priceHistoryWithTimestamp(\\n    schemaName: $schemaName\\n    contractAddress: $contractAddress\\n  ) {\\n    nodes {\\n      id\\n      latestAnswer\\n      blockNumber\\n      blockTimestamp\\n    }\\n  }\\n}\\n","variables":{"contractAddress":"0xdbe1941bfbe4410d6865b9b7078e0b49af144d2d","schemaName":"ethereum-mainnet"}}' \
--compressed)

ethResponse=$(curl -s 'https://atlas-postgraphile.public.main.prod.cldev.sh/graphql' \
-H 'authority: atlas-postgraphile.public.main.prod.cldev.sh' \
-H 'accept: */*' \
-H 'accept-language: en-US,en;q=0.9,he;q=0.8' \
-H 'content-type: application/json' \
-H 'dnt: 1' \
-H 'origin: https://data.chain.link' \
-H 'referer: https://data.chain.link/' \
-H 'sec-ch-ua: "Google Chrome";v="113", "Chromium";v="113", "Not-A.Brand";v="24"' \
-H 'sec-ch-ua-mobile: ?0' \
-H 'sec-ch-ua-platform: "macOS"' \
-H 'sec-fetch-dest: empty' \
-H 'sec-fetch-mode: cors' \
-H 'sec-fetch-site: cross-site' \
-H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36' \
--data-raw $'{"query":"\\nquery PriceHistoryQuery($schemaName: String\u0021, $contractAddress: String\u0021) {\\n  priceHistoryWithTimestamp(\\n    schemaName: $schemaName\\n    contractAddress: $contractAddress\\n  ) {\\n    nodes {\\n      id\\n      latestAnswer\\n      blockNumber\\n      blockTimestamp\\n    }\\n  }\\n}\\n","variables":{"contractAddress":"0xe62b71cf983019bff55bc83b48601ce8419650cc","schemaName":"ethereum-mainnet"}}' \
--compressed)

spyResponse=$(curl -s 'https://query1.finance.yahoo.com/v8/finance/chart/SPY?interval=2m&range=1d' \
-H 'authority: query1.finance.yahoo.com' \
-H 'accept: */*' \
-H 'accept-language: en-US,en;q=0.9,he;q=0.8' \
-H 'dnt: 1' \
-H 'origin: https://finance.yahoo.com' \
-H 'referer: https://finance.yahoo.com/quote/SPY' \
-H 'sec-ch-ua: "Google Chrome";v="113", "Chromium";v="113", "Not-A.Brand";v="24"' \
-H 'sec-ch-ua-mobile: ?0' \
-H 'sec-ch-ua-platform: "macOS"' \
-H 'sec-fetch-dest: empty' \
-H 'sec-fetch-mode: cors' \
-H 'sec-fetch-site: same-site' \
-H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36' \
--compressed)

priceSP500=$(fmt $(echo $spyResponse | parseJson "['chart']['result'][0]['meta']['regularMarketPrice']") 0)
priceBTC=$(fmt $(echo $btcResponse | parseJson "['data']['priceHistoryWithTimestamp']['nodes'][0]['latestAnswer']") 8)
priceETH=$(fmt $(echo $ethResponse | parseJson "['data']['priceHistoryWithTimestamp']['nodes'][0]['latestAnswer']") 8)

tipGwei=$(fmt $(echo $gasresponse | parseJson "['blockPrices'][0]['estimatedPrices'][0]['maxPriorityFeePerGas']") 0)
maxGwei=$(fmt $(echo $gasresponse | parseJson "['blockPrices'][0]['estimatedPrices'][0]['maxFeePerGas']") 0)

if [ "$maxGwei" -le 50 ]; then
  gasIcon="🍃"
elif [ "$maxGwei" -le 100 ]; then
  gasIcon="⛽️"
elif [ "$maxGwei" -le 200 ]; then
  gasIcon="🔥"
else
  gasIcon="💥"
fi

printf "💵${priceSP500}💰${priceBTC}💸${priceETH}${gasIcon}${tipGwei}/${maxGwei}\n"
echo "---"
echo "SP500: \$${priceSP500}"
echo "Bitcoin: \$${priceBTC}"
echo "Ethereum: \$${priceETH}"
echo "TipGas: ${tipGwei} gwei"
echo "MaxGas: ${maxGwei} gwei"
echo "$time"
