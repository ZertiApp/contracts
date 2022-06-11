//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vote {
    //Variables & init
    bool public canVote;
    address public impl;

    constructor() {
        impl = msg.sender;
        canVote = true;
    }

    /**
     * @dev  Voter info storage
     *
     * voted: O(1) check to know if user already voted
     *
     * voters: Use of heap-like structure to subdivide voters based on vote for 
     * easier processing at distributePool()
     *
     */
    mapping(address => bool) internal voted; // Voted? 
    mapping(uint8 => address[]) internal voters;
    
    /**
     * @dev  Main receiveVote function
     *
     * Receives ether and stores user vote and address in heap-like structure
     * Sets "Voted[user]" to True 
     *
     * Reward System: Generates a pool of eth for later distribution between winners(majority)
     *
     */
    function receiveVote(uint8 _userVote) external payable {
        require(msg.value==0.0001 ether,"Send 0.0001 ether");
        require(canVote == true, "Voting has ended");
        require(voted[msg.sender] == false);

        voted[msg.sender] = true;

        if(_userVote == 1){
            voters[1].push(msg.sender);
        }else{
            voters[0].push(msg.sender);
        }
    }

    /**
     * @dev  pool distribution function
     *
     * distributes reward system pool between winners(majority)
     *
     */
    function distributePool(uint8 _result,uint256 percentajePerWinner) internal {
        require(canVote == false,"Voting has ended");
        require(voters[_result].length > 0,"No votes registered"); // To avoid division by 0; if no one voted, contract balance is also 0. kill two birds with one stone.

        for(uint i = 0 ; i < voters[_result].length;) {
            payable(voters[_result][i]).transfer(percentajePerWinner);
            unchecked{ i++; } //Save gas avoiding overflow check, i is already limited to < voters[_result].length
        }
    }    

    /**
     * @dev  Vote finalization function
     *
     * Sets vote result and calls distributeVotePool() function
     *
     */
    function voteFinalization() internal {
        //TIME LOCK FUNCTION
        //MAKE THIS ONLY CALLABLE BY CONTRACT
        require(canVote == true, "Voting has ended");

        canVote = false;
        uint percentajePerWinner;
        if(voters[1].length > voters[0].length ) {
            percentajePerWinner = address(this).balance / voters[0].length;
            distributePool(1,percentajePerWinner);
        }else if (voters[1].length < voters[0].length ){
            percentajePerWinner = address(this).balance / voters[1].length;
            distributePool(0,percentajePerWinner);
        }else{
            percentajePerWinner = address(this).balance / voters[0].length + voters[1].length;
            distributePool(0,percentajePerWinner);
            distributePool(1,percentajePerWinner);
        }
    }

    //Get contract balance
    function getTotalDeposit() external view returns(uint256) {
        return address(this).balance;
    }

}