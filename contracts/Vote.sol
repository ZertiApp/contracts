//SPDX-License-Identifier: MIT

/**
 * @title Vote contract
 * @author Lucas Grasso Ramos
 * @notice Vote contract used for entity verification
 */
pragma solidity ^0.8.0;

contract Vote {
    //Variables & init
    bool internal isInitialized = false;
    address internal sender;
    address internal voteFactory; //declare as constant
    uint256 internal votingCost; //IF votingCost == 0, voting is Closed, avoids using 1 word of storage
    uint256 internal minVotes;
    uint256 internal endTime;

    function initialize(
        uint256 _votingCost,
        uint256 _minVotes,
        uint256 _timeToVote,
        address _sender 
    ) external {
        require(msg.sender == voteFactory, "Only VoteFactory can initialize");
        require(!isInitialized, "Contract is already initialized");

        isInitialized = true;
        votingCost = _votingCost;
        minVotes = _minVotes;
        endTime = block.timestamp + _timeToVote * 1 days;
        sender = _sender;
    }

    /**
     * @dev Voter info
     * @dev voted: O(1) check to know if user already voted
     * @dev voters: Use of tree structure to subdivide voters based on vote for easier processing at distributePool() function
     *              Against(0) --> [addr 1, addr 2, addr 3 ... addr n]
     *              In favour(1) --> [addr 1, addr 2, addr 3 ... addr n]
     */
    mapping(address => bool) internal voted; // Voted?
    mapping(uint8 => address[]) internal voters; // 1 - In favor vote; 0 - Opposing vote

    /**
     * @dev  Events
     */
    event UserVoted(address indexed userAddr, uint8 vote);

    event VoteFinished(uint8 result);

    /**
     * @dev Modifiers
     */
    modifier CanVote() {
        require(votingCost !=  0, "Voting has ended");
        require(block.timestamp < endTime, "Voting has ended");
        _;
    }
    modifier IsInit() {
        require(isInitialized, "Contract not initialized");
        _;
    }

    /**
     * @dev  Main receiveVote function
     * @dev receives ether and stores user's vote and address in tree structure
     * @dev Sets "Voted[user]" to True
     * @dev Reward System: Generates a pool of ether for later distribution between winners(majority)
     * @param _userVote users vote obtained in front-end. 1 - In favor vote; 0 - Opposing vote
     */
    function receiveVote(uint8 _userVote) external payable IsInit CanVote {
        require(msg.value == votingCost, "Send correct amount of ether");
        require(_userVote <= 1, "Incorrect vote");
        require(!voted[msg.sender], "User already voted");

        voters[_userVote].push(msg.sender);
        voted[msg.sender] = true;

        emit UserVoted(msg.sender, _userVote);
    }

    /**
     * @dev  Sets vote result and calls distributeVotePool() function
     */
    function voteFinalization() internal IsInit CanVote {
        require(block.timestamp > endTime, "Voting has not ended");

        votingCost = 0;

        if (voters[0].length == 0 && voters[1].length == 0) {
            revert("No voters registered");
        }

        if (voters[1].length > voters[0].length) {
            //Voters 1 > Voters 0
            unchecked {
                distributePool(address(this).balance / voters[1].length, voters[1]);
            }
            emit VoteFinished(1);
        } else if (voters[0].length > voters[1].length) {
            //Voters 0 > Voters 1
            unchecked {
                distributePool(address(this).balance / voters[0].length, voters[0]);
            }
            emit VoteFinished(0);
        } else {
            //Voters 0 = Voters 1
            uint256 percentajePerWinner;
            unchecked {
                percentajePerWinner =
                    address(this).balance /
                    (voters[0].length + voters[1].length);
            }
            distributePool(percentajePerWinner, voters[0]);
            distributePool(percentajePerWinner, voters[1]);
            emit VoteFinished(2);
        }
    }

    /**
     * @dev transfer ether to vote winners.
     * @dev  distributes reward system pool between winners(majority)
     * @param _amount ether per voter to be distributed
     */
    function distributePool(uint256 _amount, address[] memory _votersResult) internal IsInit {
        require(votingCost == 0, "Voting has not ended");
        require(block.timestamp > endTime, "Voting has not ended");
        uint winners = _votersResult.length;
        for (uint256 i = 0; i < winners;) {
            payable(_votersResult[i]).transfer(_amount);
            unchecked {
                ++i;
            } //Save gas avoiding overflow check, i is already limited to < voters[_result].length
        }
    }

    /**
     * @dev  Fallbacks functions
     */
    fallback() external payable {}

    receive() external payable {}

    /**
     * @dev Get contract balance
     * @return uint256, balance of the contract
     */
    function getTotalDeposit() external view IsInit returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev check if address has already voted
     * @param _addr address to check
     * @return bool stating if selected address has already voted
     */
    function getUserVoted(address _addr) external view IsInit returns (bool) {
        return voted[_addr];
    }

    /**
     * @dev get voting cost, if 0, voting closed
     * @return uint256, neccesary ethers to stake/vote
     */
    function getVoteCost() external view IsInit returns (uint256) {
        return votingCost;
    }

    /**
     * @dev get endTime timestamp
     * @return uint256 block.timestamp at init + n days- endTime
     */
    function getEndTime() external view IsInit returns (uint256) {
        return endTime;
    }
}
