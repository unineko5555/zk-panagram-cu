# Project Structure

## Root Directory Layout
```
zk-panagram-cu/
├── src/                    # React frontend application
├── contracts/              # Solidity smart contracts
├── circuits/               # Noir ZK circuits
├── package.json           # Node.js dependencies & scripts
├── vite.config.ts         # Vite build configuration
├── wagmi.config.ts        # Wagmi CLI configuration
├── tailwind.config.js     # TailwindCSS configuration
├── eslint.config.js       # ESLint configuration
├── tsconfig.json          # TypeScript configuration
└── CLAUDE.md              # Technical documentation
```

## Frontend Structure (`src/`)
```
src/
├── components/            # React components
│   ├── Panagram.tsx       # Main game component
│   ├── ConnectWallet.tsx  # Wallet connection
│   ├── NFTGallery.tsx     # NFT display
│   └── account.tsx        # Account management
├── utils/                 # Utility functions
├── abi/                   # Contract ABIs
├── App.tsx                # Main app component
├── main.tsx               # React entry point
├── config.ts              # Wagmi configuration
└── constant.ts            # App constants
```

## Smart Contracts (`contracts/`)
```
contracts/
├── src/                   # Contract source files
│   ├── Panagram.sol       # Main game contract
│   ├── Verifier.sol       # ZK proof verifier
│   └── metadata/          # NFT metadata files
├── test/                  # Foundry tests
│   └── Panagram.t.sol     # Comprehensive test suite
├── script/                # Deployment scripts
├── js-scripts/            # Proof generation scripts
└── foundry.toml           # Foundry configuration
```

## ZK Circuits (`circuits/`)
```
circuits/
├── src/                   # Noir source files
│   └── main.nr            # Main circuit logic
├── target/                # Compiled circuits
└── Nargo.toml             # Noir configuration
```

## Key Configuration Files
- **foundry.toml**: Solidity compiler settings, remappings for OpenZeppelin
- **Nargo.toml**: Noir circuit configuration with keccak256 dependency
- **vite.config.ts**: Modern build tool with React, buffer polyfill, Noir exclusions
- **wagmi.config.ts**: Web3 library configuration for artifact generation