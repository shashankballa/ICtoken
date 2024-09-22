
# ICtokenContract - README

This repository contains the Solidity smart contract implementing the ICtoken framework as proposed in the research paper [ICtoken: An NFT for Hardware IP Protection](#). This framework ensures end-to-end security, provenance, and integrity for Integrated Circuits (ICs) throughout their lifecycle using Non-Fungible Tokens (NFTs) on the Ethereum blockchain. The ICtoken contract is implemented using the ERC721 standard and contains functions to enroll, update, and transfer ownership of ICs in a secure and traceable manner.

## Table of Contents
- [Introduction](#introduction)
- [Requirements](#requirements)
- [Setting up Environment](#setting-up-environment)
  - [Metamask Setup](#metamask-setup)
  - [Ethereum Testnet Setup](#ethereum-testnet-setup)
  - [Remix IDE Setup](#remix-ide-setup)
- [Deploying the Contract](#deploying-the-contract)
- [Interacting with the Contract](#interacting-with-the-contract)
- [Helpful References](#helpful-references)

## Introduction

The `ICtokenContract` implements functionalities for tracking ICs' ownership, production stages, and status in the supply chain. Each IC is uniquely represented as an NFT (ICtoken), containing metadata such as the Electronic Chip Identifier (ECID), system identifiers (SID/PID), production stage, and defect status.

Key functionalities include:
- **enrollOwner**: Enrolls new owners on the blockchain.
- **enrollIC**: Enrolls new ICs and assigns them a unique ICtoken.
- **updateStage**: Updates the production stage of an IC.
- **transferIC**: Transfers ownership of an ICtoken between enrolled owners.

## Requirements

- **Metamask**: Ethereum wallet browser extension.
- **Ethereum Testnet**: For contract deployment and testing.
- **Remix IDE**: Online Solidity editor for compiling and deploying contracts.

## Setting up Environment

### Metamask Setup

1. Install the Metamask extension for your browser:
   - [Download Metamask](https://metamask.io/)
2. Create a new account or import an existing one.
3. Connect Metamask to a test network (e.g., **Goerli Testnet**):
   - Open Metamask and go to **Settings** > **Networks**.
   - Add the Goerli Testnet with the following settings:
     - **New RPC URL**: `https://rpc.goerli.mudit.blog/`
     - **Chain ID**: `5`
     - **Symbol**: `ETH`
     - **Block Explorer URL**: `https://goerli.etherscan.io`
4. Obtain test ETH by using a [Goerli Faucet](https://goerlifaucet.com/).

### Ethereum Testnet Setup

We will use the **Goerli Testnet** to deploy and test the smart contract.

1. Ensure your Metamask wallet is funded with test ETH using the Goerli Faucet.
2. Set up the Goerli network in Metamask following the steps in [Metamask Setup](#metamask-setup).

### Remix IDE Setup

1. Go to the [Remix IDE](https://remix.ethereum.org/).
2. In the Remix interface, select **Solidity** as the environment and paste the Solidity contract (`ICtokenContract`) code into the editor.
3. Ensure that Metamask is set to the Goerli Testnet to interact with Remix.

## Deploying the Contract

1. In **Remix IDE**, after pasting the contract code:
   - Go to the **Solidity Compiler** tab.
   - Select the correct compiler version (e.g., `0.8.4`) and click **Compile**.
2. Switch to the **Deploy & Run Transactions** tab:
   - Ensure the environment is set to **Injected Web3** (Metamask).
   - Select the contract (`ICtokenContract`) from the dropdown and click **Deploy**.
3. Approve the transaction in Metamask to deploy the contract to the Goerli Testnet.
4. Once deployed, the contract will appear in the **Deployed Contracts** section with its unique contract address.

## Interacting with the Contract

You can now interact with the deployed contract using the following functions:

1. **enrollOwner**:
   - Call this function to enroll your address as an owner in the system.
2. **enrollIC**:
   - Provide the ECID of the IC and enroll it on the blockchain.
3. **updateStage**:
   - Update the production stage of an IC using the `TokenUpdater` struct.
4. **transferIC**:
   - Transfer ownership of an ICtoken to another enrolled owner.

### Steps for Interaction:
1. Select the deployed contract in Remix.
2. Expand the available functions and use the input fields to test each function.
3. Monitor transactions via [Goerli Etherscan](https://goerli.etherscan.io/).

## Helpful References

Here are some useful articles to help with setting up and interacting with Ethereum smart contracts:

- [Getting Started with Solidity on Remix IDE](https://betterprogramming.pub/getting-started-with-solidity-remix-ide-858e7169d86d)
- [Deploying Smart Contracts on Ethereum Testnet](https://medium.com/coinmonks/deploying-smart-contracts-on-ethereum-testnet-e0d4a1953dfd)
- [How to Use Metamask with Ethereum Testnets](https://medium.com/metamask/how-to-use-metamask-with-testnets-2436ed3f496b)
- [Understanding ERC721 NFTs in Solidity](https://medium.com/ethereum-developers/understanding-erc721-nfts-6e9e4a6e85e4)

## License
This project is licensed under the MIT License - see the LICENSE file for details.

For more details on the research paper, you can refer to the ICtoken Paper.

---

This README provides a comprehensive guide to deploying and interacting with the `ICtokenContract`. Make sure to follow the steps carefully and reference the helpful guides linked above if you encounter any issues.