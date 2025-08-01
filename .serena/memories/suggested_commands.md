# Essential Development Commands

## Frontend Development
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Lint TypeScript/React code
npm run lint
```

## Smart Contract Development
```bash
# Navigate to contracts directory
cd contracts

# Install Foundry dependencies
forge install

# Compile contracts
forge build

# Run all tests
forge test

# Run specific test patterns
forge test --match-test "testInitialState|testContractURI"  # Lightweight tests
forge test --match-test "testCorrectGuessPasses"           # ZK proof tests

# Deploy contracts (example)
forge create src/Panagram.sol:Panagram --account <account> --rpc-url <rpc>
```

## ZK Circuit Development
```bash
# Navigate to circuits directory
cd circuits

# Compile Noir circuit
nargo compile

# Generate proof (if implemented)
nargo prove
```

## Testing & Quality Assurance
```bash
# Frontend linting
npm run lint

# Smart contract testing with coverage
cd contracts && forge test

# Type checking
tsc --noEmit
```

## Git & Development
```bash
# Standard git operations work normally on macOS
git status
git add .
git commit -m "message"
git push

# macOS-specific utilities
ls -la          # List files with details
find . -name    # Find files by name
grep -r         # Search in files
```