//SPDX-License-Identifier: MIT
pragma solidity >=0.5.3;

contract Vote {

    //Variables & init
    uint16 public YesVotes;
    uint16 public NoVotes;
    bool public canVote;
    address public impl;

    constructor() public {
        impl = msg.sender;
        canVote = true;
    }

    //Voter Storage
    mapping(address => bool[2]) voters; // [0]= Voted? [1] = Vote

    address[] votersKeys;
    
    //Main Vote Function
    function voteProposal(bool _userVote) external payable {
        require(msg.value==0.0001 ether,"Send 0.0001 ether");
        require(canVote == true, "Voting has ended");
        require(voters[msg.sender][0]== false);

        bool[2] memory voterReadOnly;
        voterReadOnly[0]= true;
        voterReadOnly[1] = _userVote;

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


    uint[] winners;

    //Distrib Pool function
    function distributePool(bool _result) external {
        require(msg.sender == address(this));
        require(canVote == false);

        for(uint i = 0; i <votersKeys.length;i++){
            if(voters[votersKeys[i]][1] == _result){
                //address payable voteWinner = payable(address(votersKeys[i]));
                winners.push(i);
            }
        }

        uint percentajePerWinner = address(this).balance / winners.lengh; //.sol no maneja floating points, revisar eso

        for(uint i = 0 ; i < winners.length; i++){
            address payable voteWinner = payable(address(votersKeys[winners[i]]));
            voteWinner.transfer(percentajePerWinner);
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