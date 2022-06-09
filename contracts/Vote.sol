pragma solidity ^0.5.3;

contract Vote {

    //Variables & init
    uint16 public YesVotes;
    uint16 public NoVotes;
    bool public canVote;
    address public impl;

    constructor() internal{
        impl = msg.sender;
        canVote = true;
    }

    //Voter Storage
    struct Voter{
        bool voted;
        bool vote;
    }

    mapping(address =>Voter) voters;
    
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

    //Get contract balance
    function getTotalDeposit() view external returns(uint256) {
        return address(this).balance;
    }

}