// Указываем версию для компилятора
pragma solidity ^0.4.11;


// Инициализация контракта
contract MyFirstERC20Coin {

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
    function MyFirstERC20Coin(){
        // Указываем число нулей
        decimals = 8;
        // Объявляем общее число токенов, которое будет создано при инициализации
        totalSupply = 10000000 * (10 ** uint256(decimals));
        // 10000000 * (10^decimals)

        // "Отправляем" все токены на баланс того, кто инициализировал создание контракта токена
        balanceOf[msg.sender] = totalSupply;

        // Указываем название токена
        name = "MyFirstERC20Coin";
        // Указываем символ токена
        symbol = "MFE";
    }

    // Внутренняя функция для перевода токенов
    function _transfer(address _from, address _to, uint256 _value) internal {
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
    function approve(address _to, uint256 _value){
        allowance[msg.sender][_to] = _value;
        Approval(msg.sender, _to, _value);
        // Вызов эвента для логгирования события одобрения перевода токенов
    }
}

contract Crowdsale {
    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);


    function Crowdsale(
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint etherCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = etherCostOfEachToken * 1 ether;
        tokenReward = token(addressOfTokenUsedAsReward);
    }


    function () payable {
        require(!crowdsaleClosed);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount / price);
        FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadline() { if (now >= deadline) _; }


    function checkGoalReached() afterDeadline {
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }


    function safeWithdrawal() afterDeadline {
        if (!fundingGoalReached) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    FundTransfer(msg.sender, amount, false);
                }
                else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }

        if (fundingGoalReached && beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                FundTransfer(beneficiary, amountRaised, false);
            }
            else {
                fundingGoalReached = false;
            }
        }
    }
}


