# MediTrace
> IFB452: Blockchain Team 14 A3
## Overview 
Fake and substandard medications are a global health threat, with the World Health Organisation (WHO) estimating 1 in 10 (10.5%) medical products in low- and middle-income countries are falsified, which leads to treatment failure, resistance, and loss of trust.

## What is Meditrace?
Meditrace is a blockchain-based pharmaceutical tracking system that ***verifies the authenticity, quality, and movement*** of drugs from origin to consumer. By leveraging blockchain technology, MediTrace aims to enhance transparency and trust within the pharmaceutical supply chain

## Features 
- **Authenticity Verification**: Ensures that medications are genuine and sourced from legitimate manufacturers.
- **Supply Chain Transparency**: This system tracks drug movements through the supply chain, providing visibility at each stage.
- **Immutable Records**: Utilises the blockchain's immutable ledger to prevent tampering and ensure data integrity.
- **Consumer Trust**: Empowers consumers with information about the origin and journey of their medications.

## Technologies Used
- **Solidity**: Smart contracts are written in Solidity to handle the logic of the pharmaceutical tracking system
- **HTML**: The front-end interface is developed using HTML, providing users with access to the system

# Getting Started
To get a local copy up and running, follow these steps:

## Prerequisites 
- [Node.js](https://nodejs.org/en) installed in your machine
- [Remix IDE](https://remix.ethereum.org/)for smart contract development
- [MetaMask](https://metamask.io/) browser extension

## How to Run MediTrace
1. **Clone** the repository
'git clone https://github.com/miuxmiyu/MediTrace.git'
2. Open 'index.html' in your browser
3. Connect **MetaMask**
   - Ensure MetaMask is added as an extension
   - Have enough Sepholia to run the application
4. Deploy Smart Contract on **Remix IDE**
   - Go to [Remix IDE](https://remix.ethereum.org/)
   - Open the 'MediTrace.sol' from the project
   - Compile the contract using the compiler
   - Deploy using **Injected Web3** environment (MetaMask)
   - Copy the deployed contract address
5. Connect **Front-End** to Deployed Contract
   - Edit the script in 'index.html' or its associated JS file
   - Replace the placeholder contract address and ABI with the deployed ones from Remix IDE.
  
## Authors
> Team 14 - IFB452 Blockchain Technology Assessment 3
@lmraad
@miuxmiyu
@brendanlen

