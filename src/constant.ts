import { keccak256 } from "ethers";

export const PANAGRAM_CONTRACT_ADDRESS = "0x8D0EF35fF6E9e4234b34B916EF842d199AB10a7a" // Replace with the actual contract address

// This is bytes32(uint256(keccak256("triangles")) % FIELD_MODULUS)
export const CORRECT_GUESS_SINGLE_HASH = "0x11212d1d1aad94d2dc18aed031902208221aa74484ac3e9122863fba27d5ca36";

// This is the double hash, which is what the circuit expects
// keccak256(abi.encodePacked(CORRECT_GUESS_SINGLE_HASH))
export const ANSWER_DOUBLE_HASH = keccak256(CORRECT_GUESS_SINGLE_HASH);

export const ANAGRAM = "GELTSRAIN"