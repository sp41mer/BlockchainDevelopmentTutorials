// Указываем версию для компилятора
pragma solidity ^0.4.11;

// Контракт для установки прав
contract OwnableWithDAO{

    // Переменная для хранения владельца контракта
    address public owner;

    // Переменная для хранения адреса DAO
    address public daoContract;

    // Конструктор, который при создании инициализирует переменную с владельцем
    function OwnableWithDAO() {
        owner = msg.sender;
    }

    // Модификатор для защиты от вызовов не создалетя контракта
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }


    // Модификатор для защиты от вызовов не со стороны DAO
    modifier onlyDAO(){
        require(msg.sender == daoContract);
        _;
    }

    // Функция для замены владельца
    function transferOwnership(address newOwner) onlyOwner public{
        require(newOwner != address(0));
        owner = newOwner;
    }

    // Функция для установки / замены контракта DAO
    function setDAOContract(address newDAO) onlyOwner public {
        daoContract = newDAO;
    }
}


// Контракт для остановки некоторых операций
contract Stoppable is OwnableWithDAO{

    // Переменная для хранения состояния
    bool public stopped;

    // Модификатор для проверки возможности выполнения функции
    modifier stoppable {
        require(!stopped);
        _;
    }

    // Функция для установки переменной в состояние остановки
    function stop() onlyDAO {
        stopped = true;
    }

    // Функция для установки переменной в состояние работы
    function start() onlyDAO{
        stopped = false;
    }
}


// Инициализация контракта
contract DAOToken is Stoppable {

    // Объявляем переменную в которой будет название токена
    string public name;
    // Объявляем переменную в которой будет символ токена
    string public symbol;
    // Объявляем переменную в которой будет число нулей токена
    uint8 public decimals;

    // Объявляем переменную в которой будет храниться общее число токенов
    uint256 public totalSupply;

    // Объявляем маппинг для хранения балансов пользователей
    mapping (address => uint256) public balanceOf;
    // Объявляем маппинг для хранения одобренных транзакций
    mapping (address => mapping (address => uint256)) public allowance;

    // Объявляем эвент для логгирования события перевода токенов
    event Transfer(address from, address to, uint256 value);
    // Объявляем эвент для логгирования события одобрения перевода токенов
    event Approval(address from, address to, uint256 value);


    // Функция инициализации контракта
    function DAOToken(){
        // Указываем число нулей
        decimals = 0;
        // Объявляем общее число токенов, которое будет создано при инициализации
        totalSupply = 10 * (10 ** uint256(decimals));
        // 10000000 * (10^decimals)

        // "Отправляем" все токены на баланс того, кто инициализировал создание контракта токена
        balanceOf[msg.sender] = totalSupply;

        // Указываем название токена
        name = "DAOCoin";
        // Указываем символ токена
        symbol = "DAO";
    }

    // Внутренняя функция для перевода токенов
    function _transfer(address _from, address _to, uint256 _value) stoppable internal {
        require(_to != 0x0);
        // Проверка на пустой адрес
        require(balanceOf[_from] >= _value);
        // Проверка того, что отправителю хватает токенов для перевода
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        //

        balanceOf[_to] += _value;
        // Токены списываются у отправителя
        balanceOf[_from] -= _value;
        // Токены прибавляются получателю

        Transfer(_from, _to, _value);
        // Перевод токенов
    }

    // Функция для перевода токенов
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
        // Вызов внутренней функции перевода
    }

    // Функция для перевода "одобренных" токенов
    function transferFrom(address _from, address _to, uint256 _value) public {
        // Проверка, что токены были выделены аккаунтом _from для аккаунта _to
        require(_value <= allowance[_from][_to]);
        allowance[_from][_to] -= _value;
        // Отправка токенов
        _transfer(_from, _to, _value);
    }

    // Функция для "одобрения" перевода токенов
    function approve(address _to, uint256 _value) public {
        allowance[msg.sender][_to] = _value;
        Approval(msg.sender, _to, _value);
        // Вызов эвента для логгирования события одобрения перевода токенов
    }

    // Функция для смены названия токена
    function changeSymbol(string _symbol) onlyDAO public {
        symbol = _symbol;
    }
}