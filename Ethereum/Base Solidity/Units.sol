pragma solidity ^0.4.0;


contract Units {

    // Time
    function getSeconds(uint a) public view returns(uint){
        return a * 1 seconds;
    }

    function getMinutes(uint a) public view returns(uint){
        return a * 1 minutes;
    }

    function getHours(uint a) public view returns(uint){
        return a * 1 hours;
    }

    function getDays(uint a) public view returns(uint){
        return a * 1 days;
    }

    function getWeeks(uint a) public view returns(uint){
        return a * 1 weeks;
    }

    function getYears(uint a) public view returns(uint){
        return a * 1 years;
    }

    // Ethers
    uint public oneWei = 1 wei;
    uint public oneFinney = 1 finney;
    uint public oneSzabo = 1 szabo;
    uint public oneEther = 1 ether;

    //Message
    bytes public msgData;
    address public msgSender;
    bytes4 public msgSig;
    uint public msgGas;
    uint public msgValue;
    uint public value;

    function setMessageValues(uint _test) public payable {
        value = _test;
        msgData = msg.data;
        msgSender = msg.sender;
        msgSig = msg.sig;
        msgGas = msg.gas;
        msgValue = msg.value;
    }
}
