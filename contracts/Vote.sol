//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/** 
 * @title Vote contract
 * @author Lucas Grasso Ramos
 * @notice Vote contract used for entity verification
*/
pragma solidity ^0.8.0;

contract Vote is Initializable {
    //Variables & init
    uint256 internal votingCost; //IF votingCost == 0, voting is Closed, avoids using 1 word of storage
    uint256 public startTime;
    uint256 public endTime;
    address public sender;

    function initialize(
        uint256 _votingCost,
        uint256 _timeToVote,
        address _sender
    ) external initializer {
        votingCost = _votingCost;
        startTime = block.timestamp;
        endTime = startTime + _timeToVote * 1 days;
        sender = _sender;
    }

    /** 
     * @dev  Voter info storage
     *
     * voted: O(1) check to know if user already voted
     *
     * voters: Use of tree structure to subdivide voters based on vote for 
     * easier processing at distributePool() function
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
    
    event VoteFinished(
        uint8 result            
    ); 

    /**
     * @dev Modifiers
     */
     modifier CanVote {
         require(votingCost > 0,"Voting has ended");
         _;
     }
    
    /**
     * @dev  Main receiveVote function
     *
     * Receives ether and stores user vote and address in tree structure
     * Sets "Voted[user]" to True 
     *
     * Reward System: Generates a pool of eth for later distribution between winners(majority)
     *
     *  @param _userVote users vote obtained in front-end. 1 - In favor vote; 0 - Opposing vote
     */
    function receiveVote(
        uint8 _userVote
        ) external payable CanVote {
        require (msg.value == votingCost,"Send correct amount of ether");
        require (_userVote <= 1, "Incorrect vote");
        require (voted[msg.sender] == false,"User already voted");

        voted[msg.sender] = true;
        voters[_userVote].push(msg.sender);

        emit UserVoted(msg.sender, _userVote);
    }

    /**
     * @dev  pool distribution function
     *
     * distributes reward system pool between winners(majority)
     *
     * @param _result proposition with the most votes.  1 - In favor vote; 0 - Opposing vote
     * @param _amount ether per voter to be distributed
     */ 
    function distributePool(
        uint8 _result, 
        uint256  _amount
        ) internal CanVote {  
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Voting has ended");    
        for(uint i = 0 ; i < voters[_result].length;) {
            payable(voters[_result][i]).transfer(_amount);
            unchecked{ i++; } //Save gas avoiding overflow check, i is already limited to < voters[_result].length
        }
    }    

    /**
     * @dev  Vote finalization function
     *
     * Sets vote result and calls distributeVotePool() function
     *
     */
    function voteFinalization() internal CanVote{

        votingCost = 0;

        if (voters[0].length == 0 && voters[1].length == 0){
            revert("No voters registered");
        }

        if (voters[1].length > voters[0].length ) { //Voters 1 > Voters 0
            emit VoteFinished(1);
            unchecked {
                distributePool(1,address(this).balance / voters[1].length);
            }
        } else if (voters[1].length < voters[0].length ) { //Voters 0 > Voters 1
            emit VoteFinished(0);
            unchecked {
                distributePool(0,address(this).balance / voters[0].length);
            }
        } else { //Voters 0 = Voters 1 
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
     * @return uint256, balance of the contract
     */
    function getTotalDeposit() external view returns(uint256) {
        return address(this).balance;
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
     * @dev get voting cost, if 0, voting closed
     * @return uint256, neccesary ethers to stake/vote
     */
    function getVoteCost() external view returns(uint256) {
        return votingCost;
    }
    /**
     * @dev get timestamps
     * @return (uint256,uint256) (block.timestamp at init, block.timestamp +  n days)
     */
    function getTime() external view returns(uint256,uint256) {
        return (startTime,endTime);
    }

}