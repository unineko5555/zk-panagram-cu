# Panagram Example On-Chain ZK App

This example is an on-chain ZK panagram game that uses Noir for the ZK circuits and Foundry for the smart contracts

## Usage 

### 1. Clone the repo

```bash
git clone https://github.com/Cyfrin/zk-panagram-cu.git
```

### 2. Install the dependencies

```bash
npm install && cd contracts && forge install
```

### 3. Running the tests

```bash
forge test
```

#### 4. (optional) re-creating the verifier

This step is needed if you modify the circuit logic at all.

1. Navigate inside the circuits folder and compile the circuit

```bash
nargo compile
```

2. Generate the verifiaction key

```bash
bb write_vk --oracle_hash keccak -b ./target/circuits.json -o ./target
```

3. Generate the verifier

```bash
bb write_solidity_verifier -k ./target/vk -o ./target/Verifier.sol
```

4. Delete your old `Verifier.sol` from inside `contracts/src` and replay with the new one!

## Running the front end 

### 1. Deploy Panagram

```bash
cd contracts && forge create src/Verifier.sol:UltraHonkVerifier --account <your-account> --rpc-url <your-rpc-url> --broadcast
```

```bash
forge create src/Panagram.sol:Panagram.sol --account <your-account> --rpc-url <your-rpc-url> --broadcast --constructor-args <your-verifier-address>
```

Then, add the address in `constants.ts`

### 2. Setup a round

Replace `"triangles"` with your desired word:

```bash
chisel

bytes32(uint256(keccak256("trianges")) % 21888242871839275222246405745257275088548364400416034343698204186575808495617)
```

Take the output and add as the input to this function call:

```bash
cast send <your-panagram-address> "newRound(bytes32)" <chisel-output>
```

Add the scrambled answer and answer hash (the chisel output) to `constants.ts`

### Run the front-end 

```bash
npx run dev
```
