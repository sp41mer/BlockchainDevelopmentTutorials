pragma solidity ^0.4.11;

contract HWL4L3Contract {
    
    address public recipient;
    uint public costOfMagic;
    string public magicMessage;
    
    function HWL4L3Contract() public {
        recipient = 0x917dDaf77Ecce6df18FDBE50Bb2fa3dd1C6cFDF5;
        costOfMagic = 2 * 1 ether;
        magicMessage = " * ADS HERE FOR 2 ETHERS ONLY * ";
    }
    
    function MagicForEhter(string _message) public payable {
        if (msg.value == costOfMagic ) {
            magicMessage = _message;
            recipient.transfer(msg.value);
        }
    }
}
