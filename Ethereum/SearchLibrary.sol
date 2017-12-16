pragma solidity ^0.4.16;

library SimpleSearch {

	function searchFor(uint[] storage self, uint _value){
		for (uint i = 0; i < self.length; i++){
			if (self[i] == _value) return i;
		}
		return uint(-1);
	}
}

contract ContractWithBigArrays {

	using SimpleSearch for uint[];

	// [1,2,3,4,5,6,7,8,9]
	uint[] bigArrayOfNumbers;

	function push(uint _value) {
		bigArrayOfNumbers.push(_value);
	}

	// 1,9 => [9,2,3,4,5,6,7,8,9]
	// 10,1 => [1,2,3,4,5,6,7,8,9,1]
	function replace(uint _old, uint _new) {
		uint position = data.searchFor(_old);
		if (position == uint(-1)){
			bigArrayOfNumbers.push(_new);
		}
		else {
			bigArrayOfNumbers[position] = _new;
		}

	}
}