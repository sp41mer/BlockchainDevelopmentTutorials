// Указываем версию Solidity
pragma solidity ^0.4.11;

// Объявляем интерфейс
interface Token {
    // Указываем, что объект этого типа имеет функцию transfer
    function transfer(address _to, uint _value) public;
}

contract TokenTransferer {

    Token token;

    function simpleInterfaceCall(address _to){
        token.transfer(_to, 2);
    }
}