// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Dark Forest
 * @dev custom “Dark Forest” (spawning only edition)
 */
interface IVerifier {
    function verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) external view returns (bool);
}

contract DarkForest {
    address public verifierAddr;

    /**
    * @dev Start the game by setting the verifier address
    * @param _verifier address of verifier contract
    */
    constructor(address _verifier) {
       verifierAddr = _verifier;
    }

    /**
    * @dev call verifyProof in verifier contract
    */
    function getVerified (
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) private view returns (bool) {
        return IVerifier(verifierAddr).verifyProof(a, b, c, input);
    }

    
    struct Player {
        uint currentPosition;
    }
    

    //mapping(address => Player) Players;

    mapping(uint => uint) History;

    mapping(address => Player) Players;

    mapping(uint => bool) Occupied;

    /** 
     * @dev It cannot be a position where other players have spawned within the last 5 minutes
     * @param position position to be spawned
     */
    function checkHistory(uint position) private view returns (bool){
        return (block.timestamp - History[position]) > 5 minutes;
    }

    /** 
     * @dev spawn players
     */
    function spawn(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input    
    ) public {
        require(checkHistory(input[0]), "Other players have spawned at this position within the last 5 minutes.");
        require(!Occupied[input[0]], "This position is currently occupied by another player.");
        require(getVerified(a, b, c, input), "Your proof is not verfied.");

        Players[msg.sender].currentPosition = input[0];
        Occupied[input[0]] = true;
        History[input[0]] = block.timestamp;
    }

}
