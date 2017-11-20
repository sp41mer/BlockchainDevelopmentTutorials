// Указываем версию для компилятора
pragma solidity ^0.4.11;

//Interface
//[{"constant":true,"inputs":[],"name":"buyPrice","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"buy","outputs":[{"name":"","type":"uint256"}],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[],"name":"token","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[{"name":"_token","type":"address"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"payable":true,"stateMutability":"payable","type":"fallback"}]


// Объявляем интерфейс
interface MyFirstERC20ICO {
    function transfer(address _receiver, uint256 _amount);
}

// Объявляем контракт
contract MyFirstSafeICO {

    // Объявляем переменную для стомости токена
    uint public buyPrice;

    // Объявялем переменную для токена
    MyFirstERC20ICO public token;


    // Функция инициализации
    function MyFirstSafeICO(MyFirstERC20ICO _token){
        // Присваиваем токен
        token = _token;
        // Присваем стоимость
        buyPrice = 1 finney;
    }

    // Функция для прямой отправки эфиров на контракт
    function () payable {
        _buy(msg.sender, msg.value);
    }

    // Вызываемая функция для отправки эфиров на контракт, возвращающая количество купленных токенов
    function buy() payable returns (uint){
        // Получаем число купленных токенов
        uint tokens = _buy(msg.sender, msg.value);
        // Возвращаем значение
        return tokens;
    }

    // Внутренняя функция покупки токенов, возвращает число купленных токенов
    function _buy(address _sender, uint256 _amount) internal returns (uint){
        // Рассчитываем стоимость
        uint tokens = _amount / buyPrice;
        // Отправляем токены с помощью вызова метода токена
        token.transfer(_sender, tokens);
        // Возвращаем значение
        return tokens;
    }
}