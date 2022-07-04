# VoteFactory.sol

We will be calling acaemic institutes and/or enterprises wishing to emit certificates entities. When one of such postulates as one, it interacts with the VoteFactory contract, which uses an upgradeable EIP1167 implementation, creating a clone of the Vote contract.

* Implements EIP1167 standard to clone instances of the Vote.sol contract.  
* Stores all deployed clones at clones mapping.  
* Stores all validated entities at entities mapping.  
* Entities interact wit this contract when postulating/repostulating.
* Badge contracts interact with IVF to check if an address is an entity.
* Devs can interact with the View Methods to retrieve information about the current state of the contract.
* Admin should interact with VoteFactory to change contract state. 

![ProxyPattern](https://user-images.githubusercontent.com/66641667/175523951-94a143a4-f573-4abb-a994-4a047ba0dc5d.png)

# Events

* ### EthReceived
    * ### Params:
        * __address indexed \_sender__
        * __uint256 \_amount__
    
    Emited at fallback function.
* ### EntityAdded
    * ### Params:
        * __address indexed \_newEntity__ -> New validated entity
        * __address \_caledBy__ -> Contract(VoteProxy) that called the function.

    Emited at Vote finish, from a Vote clone, if result if 1.
* ### ProxyCreated
    * ### Params:
        * __address indexed proxy__ -> Address of the newly created vote clone/instance.
    
    Emited at Vote cloning.
---
# Methods:
## _Entity-related methods_
### __createVote(uint256 votingCost, uint256 minVotes, uint256 timeToVote)__

### Params: 
* __votingCost:__ should be N usd, info gathered in the front-end
* __minVotes:__ minimal votes to win votation
* __timeToVote:__ days to vote, should be at least N days.

### Returns:
* A boolean value indicating whether the operation succeeded.

Can be called by everyone.
Creates an instance of the vote proxy contract and emits a {ProxyCreated} event, then initializes the Clone/Proxy.
Entities call this function at postulation.

### Reverts on:
* Invalid input(_votingCost == 0 || _minVotes < 2 || _timeToVote < 2)
* msg.sender already postulated

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
---

### __rePostulationAllowance()__

Allows entity to repostulate. If entity sends especified amount of ethers to the function, it is allowed to iniciate a new vote.
Entity should not be validated(lost at previous votation).

### Reverts on:
* Call by an already validated entity.
* msg.value != reAlowanceValue

```solidity
function rePostulationAllowance() public payable {
    if(postulations[msg.sender] && entities[msg.sender])
        revert AlreadySelectedAsEntity(msg.sender);
    if(msg.value != reAlowanceValue)
        revert InvalidInput(msg.value);
    
    postulations[msg.sender] = false;
}
```
---
## _View and info-retrieving methods_
### __getImplAddr()__

Get the current implementation Address
### Returns: 
* address of the Vote contract from which clones are created.

```solidity
function getImplAddr() external view returns (address) {
    return voteImpl;
}
```

---
### __getAdmin()__

Get the current administrator Address
### Returns: 
* address of contract admin.

```solidity
function getAdmin() external view returns (address) {
    return admin;
}
```
---
### __isEntity(\_addr)__

Check if a given address is a validated entity.

### Params:
* __\_addr__ address of the entity to be queried.
### Returns: 
* Boolean value stating if address is a validated entity.  

```solidity
function isEntity(address _addr) external view returns (bool) {
    return entities[_addr];
}
```
___
### __getPostulated(address \_addr)__

Check if a given address has postulated.

### Params:
* __\_addr__ address of the entity to be queried.
### Returns: 
* Boolean value stating if address has postulated.  

```solidity
function hasPostulated(address _addr) external view returns (bool) {
    return postulations[_addr];
}
```
---
## _Admin methods_
### __changeImpl(address \_newVoteImpl)__

### Params: 
* __\_newVoteImpl__ address of the new Vote implementation

Only callable by Admin.  
Changes the address from which vote contracts are cloned.

### Reverts on:
* Call by everyone if not Admin.

```solidity
function changeImpl(address _newVoteImpl) public onlyAdmin {
    voteImpl = _newVoteImpl;
}
```
---
### __changeAlowanceValue(uint256 \_newValue)__

### Params: 
* __\_newValue__ new amount to pay when repostulating.

Only callable by Admin.  
_newValue should be parsed as GWEI.  
Changes the value of reAlowanceValue.

### Reverts on:
* call by everyone if not Admin.
* '_newValue' equal to cero or equal to previous value.

```solidity
function changeAlowanceValue(uint256 _newValue) external payable onlyAdmin {
    if(_newValue == reAlowanceValue || _newValue == 0)
        revert InvalidInput(_newValue);
    reAlowanceValue = _newValue;
}
```
---
# Zerti
* ### [Matias Arazi](https://github.com/MatiArazi)
* ### [Lucas Grasso](https://github.com/LucasGrasso)
---
