# Panagram - Zero-Knowledge Anagram Game Platform

## Project Purpose
**Panagram** is a next-generation on-chain anagram puzzle game platform using zero-knowledge proof technology. Players can prove knowledge of correct answers while keeping them secret and earn NFT rewards.

## Core Technologies
- **Zero-Knowledge Proofs**: Using Noir language and UltraHonk proof system for secret preservation
- **Double Hash Security**: Prevents front-running and preimage attacks (2^512 security level)
- **ERC1155 NFTs**: Tiered reward system for winners
- **Smart Contracts**: Robust game logic implemented in Solidity

## Key Features
- **Front-running Prevention**: Player address embedded in proofs
- **Time-locked Rounds**: Minimum 3-hour round duration
- **NFT Reward System**: Gold NFT (first winner), Silver NFT (subsequent winners)
- **IPFS Integration**: Decentralized metadata and image management
- **Real-time Stats**: Player win counts and participation tracking

## Architecture Overview
```
Frontend (React+TS) ↔ Smart Contract (Solidity) ↔ ZK Circuit (Noir)
Wagmi/Viem          ↔ Foundry Tools            ↔ UltraHonk Proofs
```

## Security Features
- **Double Hash System**: Inner hash → Field element → Outer hash → Final field element
- **Attack Resistance**: Preimage (2^512), front-running (address-specific), dictionary attacks (custom hash path)
- **BN254 Field Operations**: Compatible with ZK circuit requirements