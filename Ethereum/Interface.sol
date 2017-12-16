pragma solidity ^0.4.11;

interface Token {
	function transfer(address _to, uint _value) public;
}

contract TokenTransferer {

	Token token;

	function simpleInterfaceCall(address _to){
		token.transfer(_to, 2);
	}
}