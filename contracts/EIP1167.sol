//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//original code
//https://solidity-by-example.org/app/minimal-proxy

 // 3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3
 // bebebebebebebebebebebebebebebebebebebebe -> impl address

contract MinimalProxy {

    event ProxyCreated(
        address proxy
    );

    function deployMinimal(address target) external returns (address result) {
        bytes20 targetBytes = bytes20(target); //convers impl address to bytes20
        assembly {
            let clone := mload(0x40) //EQU-ish, clone is a pointer
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            ) 
              /*
              |              20 bytes                |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
                                                      ^
                                                      pointer
            */
            mstore(add(clone, 0x14), targetBytes)
             /*
              |               20 bytes               |                 20 bytes              |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe
                                                                                              ^
                                                                                              pointer
            */

            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            
            /*
              |               20 bytes               |                 20 bytes              |           15 bytes          |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3
            */
            result := create(0, clone, 0x37)
        }
        emit ProxyCreated(result);
    }
}