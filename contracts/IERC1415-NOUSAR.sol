// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev Interface of the MSSBT
 */
interface ISBTDoubleSig {

    //View
    function ownerOf(uint256 _id) external view returns(address){
        return (tokens[_id].owner);
    }

    function uriOf(uint256 _id) external view returns(string memory){
        return (tokens[_id].data);
    }

    function amountOf(uint256 _id) external view returns(uint256){
        return (amount[_id]);
    }


    function tokensFrom(address _from) external view virtual returns(uint256[] memory){
        uint256 _tokenCount = 0;
        for(uint256 i = 1; i<= nonce;){
            if(owners[_from][i]){
                unchecked{
                    ++_tokenCount;
                }         
            }
            unchecked{
                ++i;
            }
        }
        uint256[] memory _myTokenes = new uint256[](_tokenCount);
         for(uint i = 1; i<=nonce;){
            if(owners[_from][i]){
                _myTokenes[--_tokenCount] = i;
            }
            unchecked{
                ++i;
            }
        }
        return _myTokenes;
    }

    function pendingFrom(address _from) external view virtual returns(uint256[] memory){
        uint256 _tokenCount = 0;
        for(uint256 i = 1; i<=nonce;){
            if(pending[_from][i]){
                ++_tokenCount;
            }
            unchecked{
                ++i;
            }
        }
        uint256[] memory _myTokenes = new uint256[](_tokenCount);
            for(uint256 i = 1; i<=nonce;){
            if(pending[_from][i]){
                _myTokenes[--_tokenCount] = i;
            }
            unchecked {
                ++i;
            }
        }
        return _myTokenes;
    }


    event TokenTransfer(
        address indexed _from,
        address indexed _to,
        uint256 _id
    );

    event TokenClaimed(
        address indexed _newOwner,
        bool claimed,
        uint256 _id
    );

    function transfer(uint256 id , address to) external returns (bool);

    function transferBatch(
        uint256 id,
        address[] memory to
    ) external returns (bool);

    

}