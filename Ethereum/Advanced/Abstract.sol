pragma solidity ^0.4.11;

contract AbstractContract {

	function test() public returns (uint);

}


contract RealContract is AbstractContract {

	function test() public returns (uint) {
		return 42;
	}
	
}