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
 * Burnable токен
 * Токен, который может быть необратимо сожжён (уничтожен).
 */
contract BurnableToken is StandardToken {
  event Burn(address indexed burner, uint256 value);
  /**
   * Сжигает определённое количество токенов.
   */
  function burn(uint256 _value) public {
    require(_value > 0);
    require(_value <= balances[msg.sender]);
    // нет необходимости проверять value <= totalSupply, так как это будет подразумевать, что
    // баланс отправителя больше, чем totalSupply, что должно привести к ошибке
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(burner, _value);
  }
}
