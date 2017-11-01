// Указываем версию солидити для компилятора
pragma solidity ^0.4.11;

//Объявляем контракт

contract HWL4L1Contract {

    uint public currentBlockNumber;
	
	function HWL4L1Contract () {
	    currentBlockNumber = 0;
	}
	
	// Метод, который устанавливает текущий номер блока в блокчейне в переменную currentBlockNumber
	function discoverCurrentBlockNumber () public{
        currentBlockNumber = block.number;
	}
}
