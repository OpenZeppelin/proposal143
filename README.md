# Compound Proposal 143 simulation 🕵️‍♂️

## Foundry Installation

*Note: [Install rust](https://www.rust-lang.org/tools/install) first*

Run the command below to get foundryup, the Foundry toolchain installer:

```
curl -L https://foundry.paradigm.xyz | bash
```

Then, in a new terminal session or after reloading your PATH, run it to get the latest forge and cast binaries:

```
foundryup
```
Advanced ways to use `foundryup`, and other documentation, can be found in the [foundryup package](./foundryup/README.md)

## Getting Started

```
git clone https://github.com/OpenZeppelin/proposal143.git
cd proposal143
forge build
```

## Instructions

```
forge test -f https://eth-mainnet.alchemyapi.io/v2/[YOUR_KEY] 
```
Note:*The test will fail if it is run after the proposal goes into an active state, but if you want to run it, try adding block 16392065 to the command and adding the "--fork-block-number" flag.*

## Features

### Testing Utilities

Includes a `Utilities.sol` contract with common testing methods (like creating users with an initial balance), as well as various other utility contracts.

### Linting

Pre-configured `solhint` and `prettier-plugin-solidity`. Can be run by

```
yarn lint
yarn format
```

### Default Configuration

Including `.gitignore`, `.vscode`, `remappings.txt`, `foundry.toml` and `.prettierignore`

### Project Configuration
Forge can be configured using a configuration file called `foundry.toml`, which is placed in the root of your project.
For more information, visit this link: https://onbjerg.github.io/foundry-book/reference/config.html
