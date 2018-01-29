pragma solidity ^0.4.11;

// Подключаем библиотеку
import 'github.com/oraclize/ethereum-api/oraclizeAPI.sol';

// Объявляем контракт
contract DollarCost is usingOraclize {

	// Объявляем переменную, в которой будем хранить стоимость доллара
	uint public dollarCost;

	// В эту функцию ораклайзер будет присылать нам результат
	function __callback(bytes32 myid, string result) public {
		// Проверяем, что функцию действительно вызывает ораклайзер
		if (msg.sender != oraclize_cbAddress()) throw;
		// Обновляем переменную со стоимостью доллара
		dollarCost = parseInt(result, 3);
	}

	// Функция для обновления курса доллара
	function updatePrice() public payable {
		// Проверяем, что хватает средств на вызов функции
		if (oraclize_getPrice("URL") > this.balance){
			// Если не хватает, просто завершаем выполнение
			return;
		} else {
			// Если хватает - отправляем запрос в API
			oraclize_query("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.[0]");
		}
	}
}