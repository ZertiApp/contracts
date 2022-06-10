//SPDX-License-Identifier: MIT
pragma solidity >=0.5.3;

contract Vote {

    //Variables & init
    uint16 public YesVotes;
    uint16 public NoVotes;
    bool public canVote;
    address public impl;

    address payable[] winners;

    constructor() public {
        impl = msg.sender;
        canVote = true;
    }

    //Voter Storage
    struct Voter{
        bool voted;
        bool vote;
    }

    mapping(address =>Voter) voters;

    address[] votersKeys;
    
    //Main Vote Function
    function voteProposal(bool _userVote) external payable {
        require(msg.value==0.0001 ether,"Send 0.0001 ether");
        require(canVote == true, "Voting has ended");
        require(voters[msg.sender].voted == false);

        Voter memory voterReadOnly;
        voterReadOnly.voted = true;
        voterReadOnly.vote = _userVote;
        voters[msg.sender] = voterReadOnly;

        if(_userVote){
            YesVotes++;
        }else{
            NoVotes++;
        }

        votersKeys.push(msg.sender);

    }

    //send ether
    function sendEther(address payable _recipient, uint _amount) external {
        _recipient.transfer(_amount);
    }

    //Distrib Pool function
    function distributePool(bool _result) external {
        require(msg.sender == address(this));
        require(canVote == false);

        for(uint i = 0; i <votersKeys.length;i++){
            if(voters[votersKeys[i]].vote == _result){
                address payable voteWinner = payable(address(votersKeys[i]));
                winners.push(voteWinner);
            }
        }

        uint percentajePerWinner = address(this).balance / winners.length; //.sol no maneja floating points, revisar eso

        for(uint i = 0 ; i < winners.length; i++){
            winners[i].transfer(percentajePerWinner);
        }
    }

    /*
    function voteFinalization() external {
        require(msg.sender == address(this));
        require(canVote == true, "Voting has ended");

        //canVote = false;
        
        if(YesVotes>NoVotes){

        }
    }
    */

    //Get contract balance
    function getTotalDeposit() view external returns(uint256) {
        return address(this).balance;
    }

}