// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Panagram} from "../src/Panagram.sol";
import {HonkVerifier, IVerifier} from "../src/Verifier.sol";

contract PanagramTest is Test {
    HonkVerifier verifier;
    Panagram panagram;

    uint256 constant FIELD_MODULUS = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    bytes32 constant ANSWER = bytes32(uint256(keccak256(abi.encodePacked(bytes32(uint256(keccak256("triangles")) % FIELD_MODULUS)))) % FIELD_MODULUS);
    bytes32 constant CORRECT_GUESS = bytes32(uint256(keccak256("triangles")) % FIELD_MODULUS);
    bytes proof;
    bytes32[] publicInputs;

    address user = makeAddr("user");

    // Events from Panagram contract for testing
    event Panagram__RoundStarted();
    event Panagram__NFTMinted(address winner, uint256 tokenId);
    event Panagram__VerifierUpdated(IVerifier verifier);
    event Panagram__ProofSucceeded(bool result);

    function setUp() public {
        verifier = new HonkVerifier();
        panagram = new Panagram(verifier);

        panagram.newRound(ANSWER);
        proof = _getProof(CORRECT_GUESS, ANSWER, user);
    }

    function _getProof(bytes32 guess, bytes32 correctAnswer, address _user) internal returns (bytes memory _proof) {
        uint256 NUM_ARGS = 6;
        string[] memory inputs = new string[](NUM_ARGS);
        inputs[0] = "npx";
        inputs[1] = "tsx";
        inputs[2] = "js-scripts/generateProof.ts";
        inputs[3] = vm.toString(guess);
        inputs[4] = vm.toString(correctAnswer);
        inputs[5] = vm.toString(bytes32(uint256(uint160(_user))));

        bytes memory result = vm.ffi(inputs);
        (_proof, /*_publicInputs*/) =
            abi.decode(result, (bytes, bytes32[]));
    }

    function testCorrectGuessPasses() public {
        vm.prank(user);
        panagram.makeGuess(proof);
        vm.assertEq(panagram.s_winnerWins(user), 1);
        vm.assertEq(panagram.balanceOf(user, 0), 1);
        vm.assertEq(panagram.balanceOf(user, 1), 0);

        // check they can't try again
        vm.prank(user);
        vm.expectRevert();
        panagram.makeGuess(proof);
    }

    function testStartNewRound() public {
        // start a round (in setUp)
        // get a winner
        vm.prank(user);
        panagram.makeGuess(proof);
        // min time passed
        vm.warp(panagram.MIN_DURATION() + 1);
        // start a new round
        panagram.newRound(bytes32(uint256(keccak256(abi.encodePacked(bytes32(uint256(keccak256("abcdefghi")) % FIELD_MODULUS)))) % FIELD_MODULUS));
        // validate the state has reset
        vm.assertEq(panagram.getCurrentPanagram(), bytes32(uint256(keccak256(abi.encodePacked(bytes32(uint256(keccak256("abcdefghi")) % FIELD_MODULUS)))) % FIELD_MODULUS));
        vm.assertEq(panagram.getCurrentRoundStatus(), address(0));
        vm.assertEq(panagram.s_currentRound(), 2);
    }

    function testIncorrectGuessFails() public {
        bytes32 INCORRECT_ANSWER = bytes32(uint256(keccak256(abi.encodePacked(bytes32(uint256(keccak256("outnumber")) % FIELD_MODULUS)))) % FIELD_MODULUS);
        bytes32 INCORRECT_GUESS = bytes32(uint256(keccak256("outnumber")) % FIELD_MODULUS);
        bytes memory incorrectProof = _getProof(INCORRECT_GUESS, INCORRECT_ANSWER, user);
        vm.prank(user);
        vm.expectRevert();
        panagram.makeGuess(incorrectProof);
    }

    function testSecondWinnerPasses() public {
        address user2 = makeAddr("user2");
        vm.prank(user);
        panagram.makeGuess(proof);
        vm.assertEq(panagram.s_winnerWins(user), 1);
        vm.assertEq(panagram.balanceOf(user, 0), 1);
        vm.assertEq(panagram.balanceOf(user, 1), 0);

        bytes memory proof2 = _getProof(CORRECT_GUESS, ANSWER, user2);
        vm.prank(user2);
        panagram.makeGuess(proof2);
        vm.assertEq(panagram.s_winnerWins(user2), 0);
        vm.assertEq(panagram.balanceOf(user2, 0), 0);
        vm.assertEq(panagram.balanceOf(user2, 1), 1);
    }

    /*//////////////////////////////////////////////////////////////
                    EDGE CASES & ERROR CONDITIONS
    //////////////////////////////////////////////////////////////*/

    function testMakeGuessBeforeFirstRound() public {
        // Create fresh contract without calling newRound
        Panagram freshPanagram = new Panagram(verifier);
        
        vm.prank(user);
        vm.expectRevert(Panagram.Panagram__FirstPanagramNotSet.selector);
        freshPanagram.makeGuess(proof);
    }

    function testNewRoundFailsWithoutWinner() public {
        // Try to start new round without any winner
        vm.warp(panagram.MIN_DURATION() + 1);
        bytes32 newAnswer = bytes32(uint256(keccak256(abi.encodePacked(bytes32(uint256(keccak256("newanswer")) % FIELD_MODULUS)))) % FIELD_MODULUS);
        
        vm.expectRevert(Panagram.Panagram__NoRoundWinner.selector);
        panagram.newRound(newAnswer);
    }

    function testNewRoundFailsBeforeMinDuration() public {
        // Get a winner first
        vm.prank(user);
        panagram.makeGuess(proof);
        
        // Try to start new round before min duration
        bytes32 newAnswer = bytes32(uint256(keccak256(abi.encodePacked(bytes32(uint256(keccak256("newanswer")) % FIELD_MODULUS)))) % FIELD_MODULUS);
        
        vm.expectRevert();
        panagram.newRound(newAnswer);
    }

    function testAlreadyAnsweredCorrectlyError() public {
        // First correct guess
        vm.prank(user);
        panagram.makeGuess(proof);
        
        // Try to guess again with same user
        vm.prank(user);
        vm.expectRevert(Panagram.Panagram__AlreadyAnsweredCorrectly.selector);
        panagram.makeGuess(proof);
    }

    /*//////////////////////////////////////////////////////////////
                            OWNER FUNCTIONS TESTS
    //////////////////////////////////////////////////////////////*/

    function testSetVerifier() public {
        HonkVerifier newVerifier = new HonkVerifier();
        
        vm.expectEmit(true, false, false, false);
        emit Panagram__VerifierUpdated(IVerifier(address(newVerifier)));
        
        panagram.setVerifier(IVerifier(address(newVerifier)));
        assertEq(address(panagram.s_verifier()), address(newVerifier));
    }

    function testSetVerifierOnlyOwner() public {
        HonkVerifier newVerifier = new HonkVerifier();
        
        vm.prank(user);
        vm.expectRevert();
        panagram.setVerifier(IVerifier(address(newVerifier)));
    }

    function testNewRoundOnlyOwner() public {
        bytes32 newAnswer = bytes32(uint256(keccak256(abi.encodePacked(bytes32(uint256(keccak256("newanswer")) % FIELD_MODULUS)))) % FIELD_MODULUS);
        
        vm.prank(user);
        vm.expectRevert();
        panagram.newRound(newAnswer);
    }

     /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS TESTS
    //////////////////////////////////////////////////////////////*/

    function testGetCurrentRoundStatus() public {
        // Initially no winner
        assertEq(panagram.getCurrentRoundStatus(), address(0));
        
        // After first winner
        vm.prank(user);
        panagram.makeGuess(proof);
        assertEq(panagram.getCurrentRoundStatus(), user);
    }

    function testGetCurrentPanagram() public {
        assertEq(panagram.getCurrentPanagram(), ANSWER);
    }

    function testContractURI() public {
        string memory expectedURI = "ipfs://bafybeicqfc4ipkle34tgqv3gh7gccwhmr22qdg7p6k6oxon255mnwb6csi/collection.json";
        assertEq(panagram.contractURI(), expectedURI);
    }

    /*//////////////////////////////////////////////////////////////
                        EVENT EMISSION TESTS
    //////////////////////////////////////////////////////////////*/

    function testRoundStartedEvent() public {
        // Get a winner first
        vm.prank(user);
        panagram.makeGuess(proof);
        
        // Wait for min duration
        vm.warp(panagram.MIN_DURATION() + 1);
        
        bytes32 newAnswer = bytes32(uint256(keccak256(abi.encodePacked(bytes32(uint256(keccak256("newanswer")) % FIELD_MODULUS)))) % FIELD_MODULUS);
        
        vm.expectEmit(false, false, false, false);
        emit Panagram__RoundStarted();
        
        panagram.newRound(newAnswer);
    }

    function testNFTMintedEventFirstWinner() public {
        vm.expectEmit(true, false, false, true);
        emit Panagram__NFTMinted(user, 0);
        
        vm.prank(user);
        panagram.makeGuess(proof);
    }

    function testNFTMintedEventSecondWinner() public {
        // First winner
        vm.prank(user);
        panagram.makeGuess(proof);
        
        // Second winner
        address user2 = makeAddr("user2");
        bytes memory proof2 = _getProof(CORRECT_GUESS, ANSWER, user2);
        
        vm.expectEmit(true, false, false, true);
        emit Panagram__NFTMinted(user2, 1);
        
        vm.prank(user2);
        panagram.makeGuess(proof2);
    }

    function testProofSucceededEventTrue() public {
        vm.expectEmit(false, false, false, true);
        emit Panagram__ProofSucceeded(true);
        
        vm.prank(user);
        panagram.makeGuess(proof);
    }

    function testProofSucceededEventFalse() public {
        bytes32 INCORRECT_ANSWER = bytes32(uint256(keccak256(abi.encodePacked(bytes32(uint256(keccak256("outnumber")) % FIELD_MODULUS)))) % FIELD_MODULUS);
        bytes32 INCORRECT_GUESS = bytes32(uint256(keccak256("outnumber")) % FIELD_MODULUS);
        bytes memory incorrectProof = _getProof(INCORRECT_GUESS, INCORRECT_ANSWER, user);
        
        vm.expectEmit(false, false, false, true);
        emit Panagram__ProofSucceeded(false);
        
        vm.prank(user);
        vm.expectRevert(Panagram.Panagram__IncorrectGuess.selector);
        panagram.makeGuess(incorrectProof);
    }

    /*//////////////////////////////////////////////////////////////
                        STATE VARIABLE TESTS
    //////////////////////////////////////////////////////////////*/

    function testInitialState() public {
        Panagram freshPanagram = new Panagram(verifier);
        
        assertEq(freshPanagram.s_currentRound(), 0);
        assertEq(freshPanagram.s_currentRoundWinner(), address(0));
        assertEq(freshPanagram.s_roundStartTime(), 0);
        assertEq(address(freshPanagram.s_verifier()), address(verifier));
        assertEq(freshPanagram.MIN_DURATION(), 10800);
    }

    function testWinnerWinsIncrement() public {
        // First round win
        vm.prank(user);
        panagram.makeGuess(proof);
        assertEq(panagram.s_winnerWins(user), 1);
        
        // Start new round
        vm.warp(panagram.MIN_DURATION() + 1);
        bytes32 newAnswer = bytes32(uint256(keccak256(abi.encodePacked(bytes32(uint256(keccak256("newanswer")) % FIELD_MODULUS)))) % FIELD_MODULUS);
        panagram.newRound(newAnswer);
        
        // Second round win
        bytes memory newProof = _getProof(
            bytes32(uint256(keccak256("newanswer")) % FIELD_MODULUS),
            newAnswer,
            user
        );
        vm.prank(user);
        panagram.makeGuess(newProof);
        
        assertEq(panagram.s_winnerWins(user), 2);
    }

    function testLastCorrectGuessRoundTracking() public {
        assertEq(panagram.s_lastCorrectGuessRound(user), 0);
        
        vm.prank(user);
        panagram.makeGuess(proof);
        
        assertEq(panagram.s_lastCorrectGuessRound(user), 1);
    }

    /*//////////////////////////////////////////////////////////////
                        ERC1155 INTEGRATION TESTS
    //////////////////////////////////////////////////////////////*/

    function testERC1155TokenURI() public {
        vm.prank(user);
        panagram.makeGuess(proof);
        
        string memory expectedURI0 = "ipfs://bafybeicqfc4ipkle34tgqv3gh7gccwhmr22qdg7p6k6oxon255mnwb6csi/0.json";
        assertEq(panagram.uri(0), expectedURI0);
        
        string memory expectedURI1 = "ipfs://bafybeicqfc4ipkle34tgqv3gh7gccwhmr22qdg7p6k6oxon255mnwb6csi/1.json";
        assertEq(panagram.uri(1), expectedURI1);
    }

    function testMultipleWinnersNFTBalance() public {
        address user2 = makeAddr("user2");
        address user3 = makeAddr("user3");
        
        // First winner gets token ID 0
        vm.prank(user);
        panagram.makeGuess(proof);
        
        // Second winner gets token ID 1
        bytes memory proof2 = _getProof(CORRECT_GUESS, ANSWER, user2);
        vm.prank(user2);
        panagram.makeGuess(proof2);
        
        // Third winner gets token ID 1
        bytes memory proof3 = _getProof(CORRECT_GUESS, ANSWER, user3);
        vm.prank(user3);
        panagram.makeGuess(proof3);
        
        // Verify balances
        assertEq(panagram.balanceOf(user, 0), 1);
        assertEq(panagram.balanceOf(user, 1), 0);
        assertEq(panagram.balanceOf(user2, 0), 0);
        assertEq(panagram.balanceOf(user2, 1), 1);
        assertEq(panagram.balanceOf(user3, 0), 0);
        assertEq(panagram.balanceOf(user3, 1), 1);
    }

   
    /*//////////////////////////////////////////////////////////////
                               FUZZ TESTS
    //////////////////////////////////////////////////////////////*/

    function testFuzzNewRoundTimestamp(uint256 timeElapsed) public {
        vm.assume(timeElapsed > 0 && timeElapsed < type(uint128).max);
        
        // Get a winner first
        vm.prank(user);
        panagram.makeGuess(proof);
        
        bytes32 newAnswer = bytes32(uint256(keccak256(abi.encodePacked(bytes32(uint256(keccak256("fuzztest")) % FIELD_MODULUS)))) % FIELD_MODULUS);
        
        if (timeElapsed < panagram.MIN_DURATION()) {
            vm.warp(timeElapsed + 1);
            vm.expectRevert();
            panagram.newRound(newAnswer);
        } else {
            vm.warp(timeElapsed + 1);
            panagram.newRound(newAnswer);
            assertEq(panagram.getCurrentPanagram(), newAnswer);
        }
    }

    function testFuzzMultipleAddresses(address randomAddr) public {
        vm.assume(randomAddr != address(0));
        vm.assume(randomAddr != user);
        
        // First winner
        vm.prank(user);
        panagram.makeGuess(proof);
        
        // Random address as second winner
        bytes memory randomProof = _getProof(CORRECT_GUESS, ANSWER, randomAddr);
        vm.prank(randomAddr);
        panagram.makeGuess(randomProof);
        
        assertEq(panagram.balanceOf(randomAddr, 1), 1);
        assertEq(panagram.s_winnerWins(randomAddr), 0);
    }
}