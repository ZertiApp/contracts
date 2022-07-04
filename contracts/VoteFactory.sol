//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./EIP1167.sol";
import "hardhat/console.sol";

/**
 * @notice interface to interact with cloned Vote contracts.
 *
 * @dev Used to call the initialize() function given that cloned contracts can not have constructors.
 */
interface Vote {
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
    uint256 internal reAlowanceValue;
    mapping(address => bool) public postulations;
    mapping(address => bool) public clones;
    mapping(address => bool) public entities;

    /**
     * @dev custom errors
     */
    error InvalidVotation(
        uint256 _votingCost,
        uint256 _minVotes,
        uint256 _timeToVote
    );

    /**
     * @dev errors
     */
    error Unauthorized(address _sender);
    error AlreadyPostulated(address _sender);
    error InvalidInput(uint256 _amount);
    error InvalidAddress(address _address);
    error AlreadySelectedAsEntity(address _sender);

    /**
     * @dev events
     */
    event EthReceived(address indexed _sender, uint256 _amount);
    event EntityAdded(address indexed _newEntity, address indexed _caledBy);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Unauthorized(msg.sender);
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
     *
     * Utilizes EIP1167 standard for cheap cloning. Creates instances of Vote contract so that each entity is voted in a separated instance.
     * emits a {ProxyCreated} event.
     *
     * @dev clone and init Vote function
     * @param _votingCost should be N usd, info gathered in the front-end
     * @param _minVotes minimal votes to win, determines entrerprise level
     * @param _timeToVote days to vote, should be at least N days.
     */
    function createVote(
        uint256 _votingCost,
        uint256 _minVotes,
        uint256 _timeToVote
    ) public payable returns(bool) {
        if (postulations[msg.sender]) revert AlreadyPostulated(msg.sender);
        if (_votingCost == 0 || _minVotes < 2 || _timeToVote < 2)
            //¡¡¡¡¡¡ONLY FOR TESTING!!!!!!!!
            revert InvalidVotation(_votingCost, _minVotes, _timeToVote);

        address _voteProxy = this.deployMinimal(voteImpl);

        console.log("Proxy created at address: %s", _voteProxy);

        Vote(_voteProxy).initialize(
            _votingCost,
            _minVotes,
            _timeToVote,
            msg.sender
        );

        postulations[msg.sender] = true;
        clones[_voteProxy] = true;

        return true;
    }

    /**
     * @dev  Allows entity to repostulate
     *
     * Entity has to pay determined value, and it may repostulate for voting
     */
    function rePostulationAllowance() public payable {
        if(postulations[msg.sender] && entities[msg.sender])
            revert AlreadySelectedAsEntity(msg.sender);
        if(msg.value != reAlowanceValue)
            revert InvalidInput(msg.value);
        
        postulations[msg.sender] = false;
    }

    /**
     * @dev  Adds an entity to the allowed entity list
     *
     * Requirements:
     * - MUST be and CAN ONLY BE called by cloned contracts from this address(addresses in the clones mapping)
     * Only callable by cloned contracts from this address.
     * Emits a {EntityAdded} event.
     *
     * @param _newEntity address of the entity to be added.
     */
    function addEntity(address _newEntity) external {
        if(clones[msg.sender] != true)
            revert Unauthorized(msg.sender);
        if(_newEntity == address(0) || msg.sender == address(0))
            revert InvalidAddress(_newEntity);
        entities[_newEntity] = true;
        emit EntityAdded(_newEntity, msg.sender);
    }

    /**
     * @dev Changes reAlowanceValue
     *
     * Only callable by admin.
     */
    function changeAlowanceValue(uint256 _newValue) external payable onlyAdmin {
        if(_newValue == reAlowanceValue || _newValue == 0)
            revert InvalidInput(_newValue);
        reAlowanceValue = _newValue;
    }



    /**
     * @dev  Fallback function
     */
    fallback() external payable {}

    /**
     * @dev  receive function
     *
     * Emits a {EthReceived} event.
     *
     */
    receive() external payable {
        emit EthReceived(msg.sender, msg.value);
    }

    /**
     * @dev get vote impl address
     *
     * @return address addr of the implementation
     */
    function getImplAddr() external view returns (address) {
        return voteImpl;
    }

    /**
     * @dev get adm addr
     *
     * @return address addr of contract admin
     */
    function getAdmin() external view returns (address) {
        return admin;
    }

    /**
     * @dev get if address is entity
     *
     * @param _addr address of the entity to be queried.
     * @return bool stating if address is a validated entity.
     */
    function isEntity(address _addr) external view returns (bool) {
        return entities[_addr];
    }
}
