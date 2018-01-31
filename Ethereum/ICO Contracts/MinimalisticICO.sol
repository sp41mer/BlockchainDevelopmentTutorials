// Указываем версию для компилятора
pragma solidity ^0.4.11;

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
        // ВНИМАНИЕ: стоимость указана в веях для одной минимальной единицы токена (0.0..decimals..1 токена)
        buyPrice = 10000;
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