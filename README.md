# MultiSender 
A smart contract enables users to bulk send ethereum / ERC20 tokens in a single transaction on ethereum network.
Upgraded to v2 to minimize risks of reentrancy attacks by using Reentrancy guard & updating the state before making low-level calls.

# Using CLI Tool

Install the packages by run `npm install` in the root folder.

Copy `.env.example` as `.env`, and replace with your configurations.

# Contracts

## Build & Deploy Contracts

Compile
```shell
npm run compile
```

Run tests
```shell
npm run test
```

Deploy & Upgrade
```shell
npm run deploy
npm run upgrade
```


