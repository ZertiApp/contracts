pragma solidity ^0.5.3;

contract Vote {
    
    string public value;
    uint16 public YesVotes;
    uint16 public NoVotes;
    bool public canVote;
    address public impl;

    constructor() internal{
        impl = msg.sender;
        canVote = true;
    }

    struct Voter{
        address voterAddr;
        bool vote;
    }

    mapping(address => bool) voterVoted;

    Voter[] voters;

    function recieve(bool _userVote) external payable {
        require(msg.value==0.0001 ether,"Send 0.0001 ether");
        require(canVote == true, "Voting has ended");
        require(voterVoted[msg.sender] == false);

        Voter memory voterReadOnly;
        voterReadOnly.voterAddr = msg.sender;
        voterReadOnly.vote = _userVote;
        voters.push(voterReadOnly); 
        voterVoted[msg.sender] = true;
        if(_userVote){
            YesVotes++;
        }else{
            NoVotes++;
        }
    }

    /*
    function distributePool(bool _result) external {
        require(msg.sender == address(this));
        require(canVote == false);

        uint16 voteWinners;

        for(uint i = 0; i <voters.length;i++){
            if(voters[i].vote == _result){
                voteWinners++;
            }
        }

        //uint percentajePerWinner = address(this).balance / voteWinners;
    }
    */

    /*
    function voteFinalization() external {
        require(msg.sender == address(this));
        require(canVote == true, "Voting has ended");

        //canVote = false;
        
        if(YesVotes>NoVotes){

        }
    }
    */

    function getTotalDeposit() view external returns(uint256) {
        return address(this).balance;
    }

}