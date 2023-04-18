# IZKPVerifier









## Methods

### getZKPRequest

```solidity
function getZKPRequest(uint64 requestId) external nonpayable returns (struct ICircuitValidator.CircuitQuery)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| requestId | uint64 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | ICircuitValidator.CircuitQuery | undefined |

### setZKPRequest

```solidity
function setZKPRequest(uint64 requestId, contract ICircuitValidator validator, uint256 schema, uint256 slotIndex, uint256 operator, uint256[] value) external nonpayable returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| requestId | uint64 | undefined |
| validator | contract ICircuitValidator | undefined |
| schema | uint256 | undefined |
| slotIndex | uint256 | undefined |
| operator | uint256 | undefined |
| value | uint256[] | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### setZKPRequestRaw

```solidity
function setZKPRequestRaw(uint64 requestId, contract ICircuitValidator validator, uint256 schema, uint256 slotIndex, uint256 operator, uint256[] value, uint256 queryHash) external nonpayable returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| requestId | uint64 | undefined |
| validator | contract ICircuitValidator | undefined |
| schema | uint256 | undefined |
| slotIndex | uint256 | undefined |
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




