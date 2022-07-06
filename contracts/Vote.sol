//SPDX-License-Identifier: MIT

/**
 * @title Vote contract
 * @author Zerti Team - Lucas Grasso Ramos
 * @notice Vote contract used for entity verification.
 */
pragma solidity ^0.8.4;

import "hardhat/console.sol";

interface IVF {
    function addEntity(
        address _newEntity
    ) external;
}

contract Vote {
    //Variables & init
    bool internal isInitialized = false;
    address internal sender;
    address internal VOTEFACTORY; //declare as constant.
    uint256 internal votingCost; //IF votingCost == 0, voting is Closed, avoids using 1 word of storage.
    uint256 internal minVotes;
    uint256 internal endTime;
    string public data;

    /**
     * @dev Voter info.
     * @dev voted: O(1) check to know if user already voted.
     * @dev voters: Use of tree structure to subdivide voters based on vote for easier processing at distributePool() function.
     *              Against(0) --> [addr 1, addr 2, addr 3 ... addr n].
     *              In favour(1) --> [addr 1, addr 2, addr 3 ... addr n].
     */
    mapping(address => bool) internal voted; // Voted?
    mapping(uint8 => address[]) internal voters; // 1 - In favor vote; 0 - Opposing vote.

    /**
     * @dev  Events
     */
    event UserVoted(address indexed userAddr, uint8 vote);

    event VoteFinished(address indexed entity, uint8 result);

    /**
     * @dev custom error msgs
     */
    error NotEnoughVotes(uint256 _votes0, uint256 _votes1);
    error NotInitialized();
    error VotingEnded();
    error InvalidVote();
    error VotingNotEnded();
    error CantInit(address _sender);
    /**
     * @dev Modifiers
     */
    modifier CanVote() {
        if (votingCost == 0 || block.timestamp > endTime) revert VotingEnded();
        _;
    }
    modifier IsInit() {
        if (!isInitialized) revert NotInitialized();
        _;
    }

    /**
     * @dev init function, given that cloned contracts cant have constructors.
     * @param _votingCost should be N usd, info gathered in the front-end.
     * @param _minVotes minimal votes to win, determines entrerprise level.
     * @param _timeToVote days to vote, should be at least N days.
     * @param _sender entity to be verified.
     */
    function initialize(
        string memory _data,
        uint256 _votingCost,
        uint256 _minVotes,
        uint256 _timeToVote,
        address _sender
    ) external {
        /*
        if (msg.sender != VOTEFACTORY || isInitialized)
            revert CantInit(msg.sender);
        */
        if (isInitialized)
            revert CantInit(msg.sender); //¡¡¡¡¡¡ONLY FOR TESTING!!!!!
        isInitialized = true;
        data = _data;
        votingCost = _votingCost * 1 ether;
        minVotes = _minVotes;
        endTime = block.timestamp + (_timeToVote * 1 days);
        sender = _sender;
        console.log("Proxy initialized correactly at address: %s", address(this) );
    }

    /**
     * @dev Get dat(URI with entity info)
     * @return string, URI,IPFS link to entity info.
     */
    function getData() external view IsInit returns (address) {
        return data;
    }

    /**
     * @dev Get entity that is being voted.
     * @return address, addr of entity being voted
     */
    function getWhoBeingVoted() external view IsInit returns (address) {
        return sender;
    }

    /**
     * @dev Get contract balance
     * @return uint256, balance of the contract.
     */
    function getTotalDeposit() external view IsInit returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev check if address has already voted
     * @param _addr address to check.
     * @return bool stating if selected address has already voted.
     */
    function getUserVoted(address _addr) external view IsInit returns (bool) {
        return voted[_addr];
    }

    /**
     * @dev check if contract is initialized
     * @return bool stating if contract is init
     */
    function getInit() external view IsInit returns (bool) {
        return isInitialized;
    }

    /**
     * @dev check against votes
     * @return uint256 n of votes against.
     */
    function getVotesAgainst() external view IsInit returns (uint256) {
        return voters[0].length;
    }

    /**
     * @dev check in favour votes
     * @return uint256 n of votes in favour.
     */
    function getVotesInFavour() external view IsInit returns (uint256) {
        return voters[1].length;
    }

    /**
     * @dev get voting cost, if 0, voting closed
     * @return uint256, neccesary ethers to stake/vote.
     */
    function getVotingCost() external view IsInit returns (uint256) {
        return votingCost;
    }

    /**
     * @dev get endTime timestamp
     * @return uint256 block.timestamp at init + timeToVote days.
     */
    function getEndTime() external view IsInit returns (uint256) {
        return endTime;
    }
    

    /**
     * @dev  Main sendVote function.
     * @dev receives ether and stores user's vote and address in tree structure.
     * @dev Sets "Voted[user]" to True.
     * @dev Reward System: Generates a pool of ether for later distribution between winners(majority).
     * @param _userVote users vote obtained in front-end. 1 - In favor vote; 0 - Opposing vote.
     */
    function sendVote(uint8 _userVote) external payable IsInit CanVote {
        if (msg.value != votingCost || _userVote >= 2 || voted[msg.sender])
            revert InvalidVote();

        voters[_userVote].push(msg.sender);
        voted[msg.sender] = true;

        emit UserVoted(msg.sender, _userVote);

        console.log("Received vote %s from %s", _userVote, msg.sender);
    }

    /**
     * @dev  Sets vote result and calls distributeVotePool() function
     */
    function voteFinalization() external IsInit CanVote { //¡¡¡ONLY FOR TESTING!!!
        votingCost = 0;
        uint256 voters0Len = voters[0].length;
        uint256 voters1Len = voters[1].length;

        if (voters0Len < minVotes && voters1Len < minVotes)
            revert NotEnoughVotes(voters0Len, voters1Len);

        if (voters1Len > voters0Len) {
            //Voters 1 > Voters 0
            distributePool(
                address(this).balance / voters1Len,
                voters[1],
                voters1Len
            ); 
            IVF(VOTEFACTORY).addEntity(sender);
            emit VoteFinished(sender, 1);
        } else if (voters0Len > voters1Len) {
            //Voters 0 > Voters 1
            distributePool(
                address(this).balance / voters0Len,
                voters[0],
                voters0Len
            );
            emit VoteFinished(sender, 0);
        } else {
            //Voters 0 = Voters 1
            uint256 percentajePerWinner;
            percentajePerWinner =
                address(this).balance /
                (voters0Len + voters1Len);
            distributePool(percentajePerWinner, voters[0], voters0Len);
            distributePool(percentajePerWinner, voters[1], voters1Len);
            emit VoteFinished(sender, 2);
        }
    }

    /**
     * @dev transfer ether to vote winners.
     * @dev  distributes reward system pool between winners(majority).
     * @param _amount ether per voter to be distributed.
     */
    function distributePool(
        uint256 _amount,
        address[] memory _votersResult,
        uint256 _resultLen
    ) internal IsInit {
        console.log("Contract balance at start is: %s gwei", address(this).balance);
        console.log("Amount to be distributed is: %s gwei", _amount);

        /* if (votingCost != 0 || block.timestamp < endTime)
            revert VotingNotEnded(); */ //¡¡¡¡ONLY FOR TESTING!!!!!!!!
        for (uint256 i = 0; i < _resultLen; ) {
            payable(_votersResult[i]).transfer(_amount);
            console.log("Contract balance at iteration n%s is: %s gwei", i+1, address(this).balance);
            unchecked {
                ++i;
            } //Save gas avoiding overflow check, i is already limited to < voters[_result].length
        }
    }

    /**
     * @dev  Fallbacks functions
     */
    fallback() external payable CanVote {}

    receive() external payable {}

}
