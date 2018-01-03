pragma solidity ^0.4.16;

contract Modifiers {

	uint constant a = 5;

	mapping (address => uint) map;
	
	function viewFunction(address _user) public view returns (uint) {
		return map[_user] * 2;
	} 

	function pureFunctionForAdd(uint _a, uint _b) public pure returns (uint) {
		return _a + _b;
	}
}