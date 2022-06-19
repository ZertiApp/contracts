//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EIP1167.sol";
import "./Vote.sol";

/**
 * @notice interface to interact with cloned Vote contracts.
 * @dev Used to call the initialize() function given that cloned contracts can't have constructors.
 */
interface VoteInit {
    function initialize(
        uint256 _votingCost,
        uint256 _minVotes,
        uint256 _timeToVote,
        address _sender
    ) external;
}

contract VoteFactory is MinimalProxy {
    address immutable internal admin;
    address internal voteImpl; //Adress of the vote contract to be cloned

    constructor() {
        admin = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == admin, "Access denied");
        _;
    }

    /**
     * @dev change implementation adress, only callable by admin
     * @param _newVoteImpl adress of the new implemention/contract to be cloned
     */
    function changeImpl(address _newVoteImpl) public onlyOwner {
        voteImpl = _newVoteImpl;
    }

    /**
     * @notice function to create an instance of Vote.sol
     * @dev clone and init Vote function
     * @param _votingCost should be N usd, info gathered in the front-end
     * @param _minVotes minimal votes to win, determines entrerprise level
     * @param _timeToVote days to vote, should be at least N days.
     */
    function createVote(
        uint256 _votingCost,
        uint256 _minVotes,
        uint256 _timeToVote
    ) public payable {
        require(_votingCost > 0, "Voting cost can't be 0");
        require(_minVotes > 50, "minVotes must be greater than 50");
        require(_timeToVote > 5, "Should at least be 5 days long");

        address voteproxy = this.deployMinimal(voteImpl);
        VoteInit(voteproxy).initialize(
            _votingCost,
            _minVotes,
            _timeToVote,
            msg.sender
        );
    }

    /**
     * @dev  Fallbacks functions
     */
    fallback() external payable {}

    receive() external payable {}

    /**
     * @dev get vote impl address
     * @return address addr of the implementation
     */
    function getImplAddr() external view returns (address) {
        return voteImpl;
    }
}
