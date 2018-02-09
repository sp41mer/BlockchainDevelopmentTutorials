pragma solidity ^0.4.11;

// Интерфейс токена
interface ChangableToken {
    function stop();
    function start();
    function changeSymbol(string name);
    function balanceOf(address user) returns (uint256);
}

// Контракт ДАО
contract DAOContract {

    // Переменная для хранения токена
    ChangableToken public token;

    // Минимальное число голосов
    uint8 public minVotes;

    // Переменная для предложенного названия
    string public proposalName;

    // Переменная для хранения состояния голосования
    bool public voteActive = false;

    // Стукрутра для голосов
    struct Votes {
        int current;
        uint numberOfVotes;
    }

    // Переменная для структуры голосов
    Votes public election;

    // Функция инициализации ( принимает адрес токена)
    function DAOContract(ChangableToken _token){
        token = _token;
    }

    // Функция для предложения нового символа
    function newName(string _proposalName) public {

        // Проверяем, что голосвание не идет
        require(!voteActive);
        proposalName = _proposalName;
        voteActive = true;

        // Остановка работы токена
        token.stop();
    }

    // Функция для голосования
    function vote(bool _vote) public {
        // Проверяем, что голосование идет
        require(voteActive);
        // Логика для голосования
        if (_vote){
            election.current += int(token.balanceOf(msg.sender));
        }
        else {
            election.current -= int(token.balanceOf(msg.sender));
        }

        election.numberOfVotes += token.balanceOf(msg.sender);

    }

    // Функция для смены символа
    function changeSymbol() public {

        // Проверяем, что голосование активно
        require(voteActive);

        // Проверяем, что было достаточное количество голосов
        require(election.numberOfVotes >= minVotes);

        // Логика для смены символа
        if (election.current > 0) {
            token.changeSymbol(proposalName);
        }
        // Сбрасываем все переменные для голосования
        election.numberOfVotes = 0;
        election.current = 0;
        voteActive = false;

        // Возобновляем работу токена
        token.start();

    }

}