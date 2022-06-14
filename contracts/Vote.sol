//SPDX-License-Identifier: MIT

/** 
 * @title Vote contract
 * @author Lucas Grasso Ramos
 * @notice Vote contract used for entity verification
*/
pragma solidity ^0.8.0;

contract Vote {
    //Variables & init
    bool internal canVote;
    uint256 internal votingCost;

    constructor() {
        canVote = true;
        votingCost = 0.0001 ether;
    }

    /** 
     * @dev  Voter info storage
     *
     * voted: O(1) check to know if user already voted
     *
     * voters: Use of tree structure to subdivide voters based on vote for 
     * easier processing at distributePool()
     *
     */
    mapping(address => bool) internal voted; // Voted? 
    mapping(uint8 => address[]) internal voters; // 1 - In favor vote; 0 - Opposing vote

    /**
     * @dev  Events
     *
     */
    event UserVoted( 
        address indexed userAddr,
        uint8 vote
    );
    
    event PaymentReleased(
        address indexed to,
        uint256 amount
    );

    event VoteFinished(
        uint8 result
    );
    
    /**
     * @dev  Main receiveVote function
     *
     * Receives ether and stores user vote and address in tree structure
     * Sets "Voted[user]" to True 
     *
     * Reward System: Generates a pool of eth for later distribution between winners(majority)
     *
     *  @param _userVote users vote. 1 - In favor vote; 0 - Opposing vote
     */
    function receiveVote(
        uint8 _userVote
        ) external payable {
        require (msg.value==votingCost,"Send 0.0001 ether");
        require (canVote == true, "Voting has ended");
        require (voted[msg.sender] == false,"User already voted");

        voted[msg.sender] = true;

        if (_userVote == 1) { 
            voters[1].push(msg.sender); //In favor
        } else {
            voters[0].push(msg.sender); //Opposing
        }

        emit UserVoted(msg.sender, _userVote);
    }

    /**
     * @dev  pool distribution function
     *
     * distributes reward system pool between winners(majority)
     *
     * @param _result proposition with the most votes.  1 - In favor vote; 0 - Opposing vote
     * @param _amount percentaje per voter to be distributed
     */ 
    function distributePool(
        uint8 _result, 
        uint256  _amount
        ) internal {      
        require (canVote == false,"Voting has ended");
        assert (address(this).balance >= _amount);
        for(uint i = 0 ; i < voters[_result].length;) {
            payable(voters[_result][i]).transfer(_amount);
            emit PaymentReleased(voters[_result][i], _amount);
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
        require (canVote == true, "Voting has ended");

        canVote = false;

        if (voters[0].length > 0 && voters[1].length > 0){
            return;
        }

        if (voters[1].length > voters[0].length ) {
            emit VoteFinished(1);
            unchecked {
                distributePool(1,address(this).balance / voters[1].length);
            }
        } else if (voters[1].length < voters[0].length ) {
            emit VoteFinished(0);
            unchecked {
                distributePool(0,address(this).balance / voters[0].length);
            }
        } else {
            uint256 percentajePerWinner;
            emit VoteFinished(2);
            unchecked {
                percentajePerWinner = address(this).balance / voters[0].length + voters[1].length;
            }
            distributePool(0,percentajePerWinner);
            distributePool(1,percentajePerWinner);
        }
    }

    /**
     * @dev  Fallbacks functions
     *
     */ 
    fallback() external payable {}
    receive() external payable {}

    /**
     * @dev  Data-Retrieving functions
     *
     * Usefull for debugging and for getting contract state info from the front-end
     *
     */ 

    /** 
     * @dev Get contract balance
     * @return uint256 with the balance of the contract
     */
    function getTotalDeposit() external view returns(uint256) {
        return address(this).balance;
    }
    /** 
     * @dev Check if you can vote
     * @return bool stating if voting is still available
     */
    function getCanVote() external view returns(bool) {
        return canVote;
    }
    /**
     * @dev check if address has already voted
     * @param _addr address to check
     * @return bool stating if selected address has already voted
     */
    function getUserVoted(address  _addr) external view returns(bool) {
        return voted[_addr];
    }
     /**
     * @dev get voting cost
     * @return uint256 of the neccesary money to stake/vote
     */
    function getVoteCost() external view returns(uint256) {
        return votingCost;
    }

}