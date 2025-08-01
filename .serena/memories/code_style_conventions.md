# Code Style & Conventions

## TypeScript/React Frontend
- **File Extensions**: `.tsx` for React components, `.ts` for utilities
- **Component Style**: Functional components with TypeScript interfaces
- **Naming**: PascalCase for components (`Panagram.tsx`), camelCase for utilities
- **Imports**: Relative imports for local files, absolute for dependencies
- **Export Style**: Default exports for main components

### Example Component Structure:
```typescript
import { WagmiProvider } from "wagmi";
import { config } from "./config";

function ComponentName() {
  return (
    <div>
      {/* JSX content */}
    </div>
  );
}

export default ComponentName;
```

## Solidity Smart Contracts
- **Version**: Pragma solidity ^0.8.24
- **Naming**: PascalCase for contracts (`Panagram.sol`)
- **State Variables**: Prefix with `s_` (e.g., `s_currentRound`)
- **Events**: Prefix with contract name (`Panagram__RoundStarted`)
- **Functions**: camelCase with clear descriptive names
- **Imports**: OpenZeppelin contracts with full paths
- **License**: MIT license header required

### Example Contract Structure:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Panagram is ERC1155 {
    uint256 public s_currentRound;
    
    event Panagram__RoundStarted();
}
```

## Noir ZK Circuits
- **File Extension**: `.nr` for Noir files
- **Function Style**: Snake_case following Rust conventions
- **Main Function**: Always named `main` with clear parameter types

## ESLint Configuration
- TypeScript ESLint rules enabled
- React hooks rules enforced  
- React refresh rules for development
- Browser globals available
- Extends recommended configs for JS and TS