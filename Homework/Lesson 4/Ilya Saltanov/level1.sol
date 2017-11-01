pragma solidity ^0.4.11;

contract HWL4L1Contract {
	
	uint public magicNumber;
    
	function HWL4L1Contract () public {
	    magicNumber = 0;
	}
	
	function setMagicNumber (uint _magicNumber) internal{
	    magicNumber = _magicNumber;
	}
	
	function MagicForFree (uint _magicNumber) public {
	    setMagicNumber(_magicNumber);
	}
}
