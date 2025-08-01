# Security Considerations & Best Practices

## Zero-Knowledge Security Model

### Double Hash System
The project implements a sophisticated double hash security system:

1. **Inner Hash**: `keccak256("answer")` → Initial hash generation  
2. **Field Element**: `% FIELD_MODULUS` → BN254 curve compatibility
3. **Outer Hash**: `keccak256(inner_hash)` → Second hash layer
4. **Final Field**: `% FIELD_MODULUS` → Circuit-compatible format

### Attack Prevention
- **Preimage Attacks**: 2^512 computational difficulty (virtually impossible)
- **Front-running**: Player address embedded in ZK proofs
- **Dictionary Attacks**: Custom hash path invalidates existing rainbow tables
- **Timing Attacks**: Constant-time ZK proof verification

## Smart Contract Security

### Access Control
- Owner-only functions for game management (`newRound`, `setVerifier`)
- Time-locks prevent premature round ending (3-hour minimum)
- Proper OpenZeppelin Ownable implementation

### State Management
- Secure round tracking with `s_currentRound`
- Winner tracking prevents duplicate rewards
- Last guess round mapping prevents replay attacks

### Field Modulus Constant
```solidity
uint256 constant FIELD_MODULUS = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
```
- BN254 elliptic curve field size for ZK circuit compatibility
- Prevents overflow in field operations

## Development Security Practices

### Code Review Requirements
- All smart contract changes must pass 30 comprehensive tests
- ZK circuit modifications require proof generation validation
- Frontend changes need E2E testing verification

### Testing Standards
- 100% test coverage for smart contracts
- Fuzz testing for edge cases
- Integration testing for ZK proof flows
- Gas optimization analysis for cost efficiency

### Deployment Security
- Verifier contract deployment verification
- Contract address validation in frontend
- IPFS metadata integrity checks
- Network-specific configuration management

## Common Vulnerabilities to Avoid
- **Reentrancy**: Not applicable (no external calls in critical functions)
- **Integer Overflow**: Solidity 0.8.24 has built-in overflow protection
- **Front-running**: Mitigated by address-specific ZK proofs
- **Signature Replay**: Prevented by round-specific state tracking