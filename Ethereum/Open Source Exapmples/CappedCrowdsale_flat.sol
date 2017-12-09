pragma solidity ^0.4.11;
/**
 * ERC20Basic
 * Простая версия интерфейса ERC20
 * смотри https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
/**
 * Ownable
 * Контракт Ownable имеет адрес владельцаи предоставляет функции базового контроля авторизации,
 * это упрощает реализацию "пользовательских прав".
 */
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  /**
   * Конструктор Ownable задаёт владельца контракта с помощью аккаунта отправителя
   */
  function Ownable() {
    owner = msg.sender;
  }
  /**
   * Выбрасывает ошибку, если вызвана любым аккаунтом, кроме владельца.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  /**
   * Позволяет текущему владельцу перевести контроль над контрактом новому владельцу.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
/**
 * SafeMath
 * Математические операторы с проверками ошибок
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity автоматически выбрасывает ошибку при делении на ноль, так что проверка не имеет смысла
    uint256 c = a / b;
    // assert(a == b * c + a % b); // Не существует случая, когда эта проверка не была бы пройдена
    return c;
  }
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
/**
 * Basic token
 * Базовая версия стандартного токена StandardToken, без допуска (без allowance).
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  /**
  * Переводит токены на заданный адрес.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    // SafeMath.sub выбросит ошибку, если денег для перевода недостаточно.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }
  /**
  * Получает баланс указанного адреса.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}
/**
 * Интерфейс ERC20
 * подробнее https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
/**
 * Стандартный ERC20 токен
 * Реализация базового стандартного токена.
 * https://github.com/ethereum/EIPs/issues/20
 * Основано на коде от FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) internal allowed;
  /**
   * Переводит токены с одного адреса на другой.
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
  /**
   * Подтверждение для конкретного адреса на перевод указанного количества токенов от msg.sender.
   *
   * Будьте осторожны, так как изменение allowance этим методом приносит риск того, что кто-нибудь может использовать
   * оба старый и новый allowance путем неудачного порядка транзакций. Одно из возможных решений для смягчения этого
   * состояния гонки заключается в том, чтобы сначала уменьшить допуск (allowance) отправителя до 0 и затем установить
   * желаемое значение:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
  /**
   * Функция проверки количества токенов, которые владелец разрешил потратить конкретному адресу.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
  /**
   * подтверждение (Approval) должно быть получено, когда allowed[_spender] == 0. Чтобы увеличить
   * разрешённое количество, лучше использовать эту функцию, чтобы избежать двух вызовов (и ждать, пока
   * первая транзакция смайнится)
   * Из MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}
/**
 * Mintable token
 * Простой пример токена ERC20, с созданием mintable токена
 * Основано на коде TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  bool public mintingFinished = false;
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}
/**
 * Crowdsale
 * Crowdsale - базовый контракт для управления проведением crowdsale для токена.
 * Crowdsale имеет начало и конец в формате timestamp, когда инвесторы могут делать
 * покупку токенов, и crowdsale присвоит им токены на основании
 * курса к ETH. Собранные вложения отправляются на кошелёк, как только они поступают
 */
contract Crowdsale {
  using SafeMath for uint256;
  // Токен продаётся
  MintableToken public token;
  // timestamps начала и конца, когда инвестиции разрешены (оба включительно)
  uint256 public startTime;
  uint256 public endTime;
  // адрес, на который переводятся вложения
  address public wallet;
  // как много токенов покупатель получает ща свои wei
  uint256 public rate;
  // количество собранных денег в wei
  uint256 public weiRaised;
  /**
   * event для логгирования покупки токенов
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));
    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }
  // создаёт токен для продажи.
  // перегрузи этот метод, чтобы провести crowdsale для определенного mintable токена.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }
  // функция, которая может быть использована для покупки токенов
  function () payable {
    buyTokens(msg.sender);
  }
  // низкоуровневая функция для покупки токенов
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());
    uint256 weiAmount = msg.value;
    // вычислить количество создаваемых токенов
    uint256 tokens = weiAmount.mul(rate);
    // обновить состояние
    weiRaised = weiRaised.add(weiAmount);
    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    forwardFunds();
  }
  // отправить эфиры на кошелёк для сбора взносов
  // перегрузить для создания своих механизмов отправки взносов
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }
  // возвращает true, если транзакция может купить токен
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }
  // возвращает true, если crowdsale закончился
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }
}
/**
 * CappedCrowdsale
 * Расширение Crowdsale с максимальным количеством собрираемых взносов
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;
  uint256 public cap;
  function CappedCrowdsale(uint256 _cap) {
    require(_cap > 0);
    cap = _cap;
  }
  // возвращает true, если инвесторы мог купить в данный момент
  function validPurchase() internal constant returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }
  // возвращает true, если crowdsale закончился
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }
}
