#!/bin/zsh

# Prints SP500, BTC price, ETH price, gas, time in LA NY UTC

time="⌚LA:$(TZ=America/Los_Angeles date +'%H') NY:$(TZ=America/New_York date +'%H') UTC:$(TZ=UTC date +'%H')"

btcResponse=$(FOUNDRY_ETH_RPC_URL="https://rpc.ankr.com/eth" cast call btc-usd.data.eth "latestAnswer()(uint256)")
ethResponse=$(FOUNDRY_ETH_RPC_URL="https://rpc.ankr.com/eth" cast call eth-usd.data.eth "latestAnswer()(uint256)")
spyResponse=$(FOUNDRY_ETH_RPC_URL="https://rpc.ankr.com/eth" cast call cspx-usd.data.eth "latestAnswer()(uint256)")
gasResponse=$(FOUNDRY_ETH_RPC_URL="https://rpc.ankr.com/eth" cast call fast-gas-gwei.data.eth "latestAnswer()(uint256)")

priceBTC=$(bc <<< "scale=0; ${btcResponse}/1e8")
priceETH=$(bc <<< "scale=0; ${ethResponse}/1e8")
priceSP500=$(bc <<< "scale=0; ${spyResponse}/1e8")
gas=$(bc <<< "scale=0; ${gasResponse}/1e9")

if [ "$gas" -le 50 ]; then
  gasIcon="🍃"
elif [ "$gas" -le 100 ]; then
  gasIcon="⛽️"
elif [ "$gas" -le 200 ]; then
  gasIcon="🔥"
else
  gasIcon="💥"
fi

printf "💵${priceSP500}💰${priceBTC}💸${priceETH}${gasIcon}${gas}\n"
echo "---"
echo "S&P500: \$${priceSP500}"
echo "Bitcoin: \$${priceBTC}"
echo "Ethereum: \$${priceETH}"
echo "Gas: ${gas} gwei"
echo "$time"
