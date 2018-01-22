pragma solidity ^0.4.0;



contract Types {

    // Integer

    int public a = 8;
    uint public b = 8;

    function plus(int x) public view returns(int){
        return a + x;
    }

    function plus_u(uint x) public returns(uint){
        return b + x;
    }

    function minus(int x) public view returns(int){
        return a - x;
    }

    function minus_u(uint x) public view returns(uint){
        return b - x;
    }

    function mul(int x) public view returns(int) {
        return a * x;
    }

    function mul_u(uint x) public view returns(uint){
        return b * x;
    }

    function div(int x) public view returns(int) {
        return a / x;
    }

    function div_u(uint x) public view returns(uint){
        return b / x;
    }

    // String

    string public simpleString = "Привет из смарт-контракта !";

    function changeString(string _newString) public {
        simpleString = _newString;
    }

    // Array

    uint[] public simpleArray;

    function push(uint _value) public {
        simpleArray.push(_value);
    }

    // Mapping

    mapping(uint => uint) public simpleMapping;

    function add(uint _key, uint _value) public {
        simpleMapping[_key] = _value;
    }

    // Struct

    struct Client {
        string name;
        string lastName;
        uint age;
    }

    Client[] public clients;

    mapping(uint => Client) public clientsMap;

    function addToArray(string _name, string _lastName, uint _age) public {
        clients.push(Client({name: _name, lastName: _lastName, age: _age}));
    }

    function addToMap(uint _nickname, string _name, string _lastName, uint _age) public {
        clientsMap[_nickname] = Client({name: _name, lastName: _lastName, age: _age});
    }


}
