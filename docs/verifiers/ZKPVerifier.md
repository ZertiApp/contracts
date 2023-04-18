# ZKPVerifier









## Methods

### getSupportedRequests

```solidity
function getSupportedRequests() external view returns (uint64[] arr)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| arr | uint64[] | undefined |

### getZKPRequest

```solidity
function getZKPRequest(uint64 requestId) external view returns (struct ICircuitValidator.CircuitQuery)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| requestId | uint64 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | ICircuitValidator.CircuitQuery | undefined |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### proofs

```solidity
function proofs(address, uint64) external view returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| _1 | uint64 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### requestQueries

```solidity
function requestQueries(uint64) external view returns (uint256 schema, uint256 claimPathKey, uint256 operator, uint256 queryHash, string circuitId)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | uint64 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| schema | uint256 | undefined |
| claimPathKey | uint256 | undefined |
| operator | uint256 | undefined |
| queryHash | uint256 | undefined |
| circuitId | string | undefined |

### requestValidators

```solidity
function requestValidators(uint64) external view returns (contract ICircuitValidator)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | uint64 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract ICircuitValidator | undefined |

### setZKPRequest

```solidity
function setZKPRequest(uint64 requestId, contract ICircuitValidator validator, uint256 schema, uint256 claimPathKey, uint256 operator, uint256[] value) external nonpayable returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| requestId | uint64 | undefined |
| validator | contract ICircuitValidator | undefined |
| schema | uint256 | undefined |
| claimPathKey | uint256 | undefined |
| operator | uint256 | undefined |
| value | uint256[] | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### setZKPRequestRaw

```solidity
function setZKPRequestRaw(uint64 requestId, contract ICircuitValidator validator, uint256 schema, uint256 claimPathKey, uint256 operator, uint256[] value, uint256 queryHash) external nonpayable returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| requestId | uint64 | undefined |
| validator | contract ICircuitValidator | undefined |
| schema | uint256 | undefined |
| claimPathKey | uint256 | undefined |
| operator | uint256 | undefined |
| value | uint256[] | undefined |
| queryHash | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### submitZKPResponse

```solidity
function submitZKPResponse(uint64 requestId, uint256[] inputs, uint256[2] a, uint256[2][2] b, uint256[2] c) external nonpayable returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| requestId | uint64 | undefined |
| inputs | uint256[] | undefined |
| a | uint256[2] | undefined |
| b | uint256[2][2] | undefined |
| c | uint256[2] | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |



## Events

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |



