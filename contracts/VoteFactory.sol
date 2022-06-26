//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./EIP1167.sol";
import "hardhat/console.sol";

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
    address internal immutable admin;
    address internal voteImpl; //Adress of the vote contract to be cloned
    mapping(address => bool) public postulations;

    /**
     * @dev custom errors
     */
    error InvalidVotation(
        uint256 _votingCost,
        uint256 _minVotes,
        uint256 _timeToVote
    );
    error unauthorized(address _sender);
    error AlreadyPostulated(address _sender);
    error InvalidAmount(uint256 _amount);
    error AlreadySelectedAsEntity(address _sender);

    /**
     * @dev events
     */
    event EthReceived(address _sender, uint256 _amount);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        if (msg.sender != admin) revert unauthorized(msg.sender);
        _;
    }

    /**
     * @dev change implementation adress, only callable by admin
     * @param _newVoteImpl adress of the new implemention/contract to be cloned
     */
    function changeImpl(address _newVoteImpl) public onlyAdmin {
        voteImpl = _newVoteImpl;
        console.log("New implementation address is: %s", _newVoteImpl);
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
        if (postulations[msg.sender]) revert AlreadyPostulated(msg.sender);
        if (_votingCost == 0 || _minVotes < 2 || _timeToVote < 2)
            //¡¡¡¡¡¡ONLY FOR TESTING!!!!!!!!
            revert InvalidVotation(_votingCost, _minVotes, _timeToVote);

        address _voteProxy = this.deployMinimal(voteImpl);

        console.log("Proxy created at address: %s", _voteProxy);

        VoteInit(_voteProxy).initialize(
            _votingCost,
            _minVotes,
            _timeToVote,
            msg.sender
        );

        postulations[msg.sender] = true;
    }

    /**
     * @dev  Allows entity to repostulate
     */
    function rePostulationAllowance() public payable {
        if(postulations[msg.sender])
            revert AlreadySelectedAsEntity(msg.sender);
        if(msg.value != 10 ether)
            revert InvalidAmount(msg.value);
        
        postulations[msg.sender] = false;
    } 

    /**
     * @dev  Fallbacks functions
     */
    fallback() external payable {}

    receive() external payable {
        emit EthReceived(msg.sender, msg.value);
    }

    /**
     * @dev get vote impl address
     * @return address addr of the implementation
     */
    function getImplAddr() external view returns (address) {
        return voteImpl;
    }

    /**
     * @dev get adm addr
     * @return address addr of contract admin
     */
    function getAdmin() external view returns (address) {
        return admin;
    }
}
