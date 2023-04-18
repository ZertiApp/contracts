# CredentialAtomicQueryMTPValidator









## Methods

### getChallengeInputIndex

```solidity
function getChallengeInputIndex() external pure returns (uint256 index)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| index | uint256 | undefined |

### getCircuitId

```solidity
function getCircuitId() external pure returns (string id)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| id | string | undefined |

### initialize

```solidity
function initialize(address _verifierContractAddr, address _stateContractAddr) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _verifierContractAddr | address | undefined |
| _stateContractAddr | address | undefined |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### revocationStateExpirationTime

```solidity
function revocationStateExpirationTime() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### setRevocationStateExpirationTime

```solidity
function setRevocationStateExpirationTime(uint256 expirationTime) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| expirationTime | uint256 | undefined |

### state

```solidity
function state() external view returns (contract IState)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IState | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |

### verifier

```solidity
function verifier() external view returns (contract IVerifier)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IVerifier | undefined |

### verify

```solidity
function verify(uint256[] inputs, uint256[2] a, uint256[2][2] b, uint256[2] c, uint256 queryHash) external view returns (bool r)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| inputs | uint256[] | undefined |
| a | uint256[2] | undefined |
| b | uint256[2][2] | undefined |
| c | uint256[2] | undefined |
| queryHash | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| r | bool | undefined |



## Events

### Initialized

```solidity
event Initialized(uint8 version)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| version  | uint8 | undefined |

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |



