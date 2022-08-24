# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

all: clean install update build 

# deps
install:; forge install
update:; forge update

# Build & test
build    :; forge build
test     :; forge test
test_f	 :; forge test --fork-url ${MAINNET_RPC} --etherscan-api-key ${ETHERSCAN_KEY}
trace    :; forge test -vvvvv
clean    :; forge clean
snapshot :; forge snapshot
fmt      :; forge fmt

