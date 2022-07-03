# VoteFactory.sol

Implements EIP1167 standard to clone instances of the vote.sol contract.

## Events

* EthReceived
    * Params:
        * address indexed _sender
        * uint256 _amount
    
    Emited at fallback function.
* EntityAdded
    * Params:
        * address indexed _newEntity
        * address _caledBy

    Emited at Vote finish, from a Vote clone, if result if 1.
* ProxyCreated
    * Params:
        * address indexed proxy
    
    Emited at Vote cloning.

## Methods:

__createVote()__

* Params: 
    * votingCost should be N usd, info gathered in the front-end
    * minVotes minimal votes to win votation
    * timeToVote days to vote, should be at least N days.

Can be called by everyone.
Creates an instance of the vote proxy contract and emits the {ProxyCreated} event, then initializes the clone or proxy.

```solidity
function createVote(
        uint256 _votingCost,
        uint256 _minVotes,
        uint256 _timeToVote
    ) public payable {
        address _voteProxy = this.deployMinimal(voteImpl);

        Vote(_voteProxy).initialize(
            _votingCost,
            _minVotes,
            _timeToVote,
            msg.sender
        );

        postulations[msg.sender] = true;
        clones[_voteProxy] = true;
    }
```