pragma solidity ^0.4.11;

contract HWL4L2Contract {
	uint public costOfMagic;
	uint public magicNumber;
	
  function HWL4L2Contract () public {
	    magicNumber = 0;
	    costOfMagic = 1 * 1 ether;
	}
	
	function setMagicNumber (uint _magicNumber) internal{
	    magicNumber = _magicNumber;
	}
    
  function MagicForEther(uint _magicNumber ) public payable {
	
      if (msg.value == costOfMagic ) {
         setMagicNumber(_magicNumber);
      }
  }
}
