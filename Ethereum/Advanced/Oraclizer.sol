pragma solidity ^0.4.11;

import 'github.com/oraclize/ethereum-api/oraclizeAPI.sol';

contract DollarCost is usingOraclize {

	uint public dollarCost;

	function __callback(bytes32 myid, string result){
		if (msg.sender != oraclize_cbAddress()) throw;
		dollarCost = parseInt(result, 3);
	}

	function updatePrice() payable {

		if (oraclize_getPrice("URL") > this.balance){
			return;
		} else {
			oraclize_query("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.[0]");
		}
	}
}