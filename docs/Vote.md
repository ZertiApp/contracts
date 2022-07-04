# Vote.sol

For each Vote contract, users are able to create a "Voting Pool" and to determine if the entity in question should be considered as such. Each vote has its time limit,  minimum votes and voting cost required. It is important to consider that results are given by majority and that each clone of the Vote contract acts independentely.
Each postulations has it own Vote.sol instance.

* Implements the DAO Voting System.
* Implements the Voting-Pool Reward System.
* Users(voters) interact with cloned instances(See VoteFactory.sol) of this contract.
* Can be upgraded via VoteFactory(See VoteFactory.sol).
* Calls _addEntity(See VoteFactory.sol) if result is 1(True/In favour).
* Stores votes in tree-like structure based on vote(0- Votes Against ; 1-Votes in Favour)
* Implements a time-lock function, restricting function calls when block.timestamp at call exceeds timeToVote
* At vote finish, distributes the pool according to majoritarian vote.

![VotingPoolPattern](https://user-images.githubusercontent.com/66641667/175523913-0492bb02-2f5b-4c83-a5d6-2e5a9e12f1a9.png)
__Voting Pool:__ Stake-ish MATIC (ethers) pool formed by the tokens sent by Users. It is distributed based on majoritarian vote, generating a reward system for people in order to incentivate entity verification.
![DistributePoolPattern](https://user-images.githubusercontent.com/66641667/175523873-1a9dae75-0776-4e97-956e-279b123273ec.png)
When a vote finishes, the pool is distributed based on majoritarian vote. This system's sole objective is to incentivate entity verification for the community.

# Events

* ### UserVoted
    * ### Params:
        * __address indexed userAddr__ --> address of the voter
        * __uint8 vote__ --> (0- Vote Against ; 1-Vote in Favour)

    Emmited at each sendVote() call (See sendVote())

* ### VoteFinished
    * ### Params:
        * __address indexed entity__ --> address of the entity being voted
        * __uint8 vote__ --> (0- Vote lost, entity is not validated ; 1- Vote win, entity is now validated and can emit certificates)

    emited at voteFinalization()(See voteFinalization())
---
# Methods:

### __initialize(uint256 \_votingCost, uint256 \_minVotes, uint256 \_timeToVote, address \_sender)__

### Params: 
* __votingCost:__ should be N usd, info gathered in the front-end
* __minVotes:__ minimal votes to win votation
* __timeToVote:__ days to vote, should be at least N days.
* __\_sender:__ entity to be verified.

### Reverts on:
* Already initialized at call
* Call by everyone, if not VoteFactory.


init function, given that cloned contracts cant have constructors. Only callable by VoteFactory contract. Only callable once(It is like a constructor)

```solidity
function initialize(
    uint256 _votingCost,
    uint256 _minVotes,
    uint256 _timeToVote,
    address _sender
) external {
    if (msg.sender != VOTEFACTORY || isInitialized)
        revert CantInit(msg.sender);
    isInitialized = true;
    votingCost = _votingCost * 1 ether;
    minVotes = _minVotes;
    endTime = block.timestamp + (_timeToVote * 1 days);
    sender = _sender;
}
```
---
### __sendVote(uint8 \_userVote)__

### Params:
* __\_userVote:__ users vote obtained in front-end. 1 - In favor vote; 0 - Opposing vote.

### Reverts on:
* msg.value not equal to votingCost.
* msg.sender already voted.
* Not initialized
* block.timestamp at call exceeds set time.
* Voting finished.

Main voting function.  
Users should send correct amount of ethers to vote. Determined at init. and obtainable at getVotingCost().  
Receives ether and stores user's vote and address in tree structure.  
Sets that user has voted.  
Emits a {UserVoted} event.

```solidity
function sendVote(uint8 _userVote) external payable IsInit CanVote {
    if (msg.value != votingCost || _userVote >= 2 || voted[msg.sender])
        revert InvalidVote();

    voters[_userVote].push(msg.sender);
    voted[msg.sender] = true;

    emit UserVoted(msg.sender, _userVote);
}
```
---
## View and Info-Retrieving functions
### getWhoBeingVoted()
Get entity that is being voted.

### Returns:
* address of entity being voted
---
### getTotalDeposit()
Get contract balance

### Returns:
* uint256, balance of the contract(IN GWEI).
---
### getUserVoted(address _addr)
Check if address has already voted

### Params: 
* __\_addr__ address to check.

### Returns:
* boolean value stating if selected address has already voted.
---
### getInit()
Check if contract is initialized

### Returns:
* boolean value stating if contract is initiliazed
---
### getVotesAgainst()
Check against votes

### Returns:
* uint256, number of votes against.
---
### getVotesInFavour()
Check in favour votes

### Returns:
* uint256, number of votes in favour.
---
### getVotingCost()
get voting cost, if 0, voting closed

### Returns: 
* uint256, neccesary ethers to stake/vote(IN GWEI)
---
### getEndTime()
Get endTime timestamp(Unix Time)

### Returns:
* uint256, block.timestamp at init + timeToVote days.
---
## _Internal Functions_
### __voteFinalization()__

Sets vote result and calls distributeVotePool() function

internal and should only be called by an Admin contract.
Emits a {VoteFinished} event; and calls distributePool().

### distributePool()
Transfers ether to vote winners.
Distributes reward system pool between winners(majority).  

``` solidity
function distributePool(
    uint256 _amount,
    address[] memory _votersResult,
    uint256 _resultLen
) internal IsInit {
    if (votingCost != 0 || block.timestamp < endTime)
        revert VotingNotEnded(); 
    for (uint256 i = 0; i < _resultLen; ) {
        payable(_votersResult[i]).transfer(_amount);
        unchecked {
            ++i;
        }
    }
```

---
###
# Zerti
* ### [Matias Arazi](https://github.com/MatiArazi)
* ### [Lucas Grasso](https://github.com/LucasGrasso)
---