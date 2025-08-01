# Task Completion Checklist

## When completing development tasks, always run:

### 1. Code Quality Checks
```bash
# Run ESLint for frontend code
npm run lint

# TypeScript compilation check
tsc --noEmit
```

### 2. Smart Contract Validation
```bash
# Navigate to contracts directory
cd contracts

# Compile contracts
forge build

# Run comprehensive test suite (30 tests)
forge test

# For specific test categories:
forge test --match-test "testInitialState|testContractURI"  # Lightweight tests
forge test --match-test "testCorrectGuessPasses"           # ZK proof tests
```

### 3. ZK Circuit Validation
```bash
# Navigate to circuits directory
cd circuits

# Compile Noir circuit
nargo compile
```

### 4. Build Verification
```bash
# Frontend build check
npm run build

# Preview production build (optional)
npm run preview
```

## Important Notes
- **Never commit** without running tests first
- **Always check** that `forge test` passes with 100% success rate
- **Lint issues** must be resolved before committing
- **ZK circuit compilation** must succeed for proof generation
- **Build process** must complete without errors
- **Gas optimization** should be considered for contract changes

## Testing Standards
- Smart contracts: 100% test coverage (30 comprehensive tests)
- Frontend: Unit tests with Jest + RTL (mentioned in CLAUDE.md)
- E2E: Playwright browser testing (mentioned in CLAUDE.md)
- All tests must pass before considering task complete

## Deployment Prerequisites
- Verifier contract must be deployed first
- Panagram contract deployed with verifier address
- NFT metadata properly configured on IPFS
- Frontend configured with correct contract addresses