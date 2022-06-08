pragma solidity ^0.5.3;

contract Vote {
    
    string public value;
    uint16 public YesVotes;
    uint16 public NoVotes;
    bool public canVote;

    struct Voter{
        address voterAddr;
        bool vote;
    }

    Voter[] voters;

    function recieve(bool _userVote) external payable {
        require(msg.value==0.0001 ether,"Send 0.0001 ether");
        require(canVote == true, "Voting has ended");
        Voter memory voterReadOnly;
        voterReadOnly.voterAddr = msg.sender;
        voterReadOnly.vote = _userVote;
        voters.push(voterReadOnly); 
        if(_userVote){
            YesVotes++;
        }else{
            NoVotes++;
        }
    }

    function voteFinalization() external {
        require(canVote == true, "Voting has ended");
        canVote = false;
        /*
        if(YesVotes>NoVotes){

        }*/
    }

    function getTotalDeposit() view external returns(uint) {
        return address(this).balance;
    }
}