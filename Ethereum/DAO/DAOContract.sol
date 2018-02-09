pragma solidity ^0.4.11;

interface ChangeNameToken{
    function stop();
    function start();
    function changeSymbol(string name);
    function balanceOf(address user) returns (uint256);
}


contract DAOContract {

    ChangeNameToken public token;

    uint8 public minVotes = 6;

    string public proposalName;

    bool public voteActive = false;

    struct Votes {
    int current;
    uint numberOfVotes;
    }

    Votes public election;

    function DAOContract(ChangeNameToken _token){
        token = _token;
    }

    // Фукнция для предложения нового имени
    function newName(string _proposalName) public {
        // Проверяем, что голосование не идет сейчас
        require(!voteActive);
        proposalName = _proposalName;
        voteActive = true;
        token.stop();
    }

    // Фукнция для голосования
    function vote(bool _vote) public {
        // Проверяем, что идет голосование
        require(voteActive);

        // Логика для голования
        if (_vote){
            election.current += int256(token.balanceOf(msg.sender));
        }
        else {
            election.current -= int256(token.balanceOf(msg.sender));

        }
        election.numberOfVotes += token.balanceOf(msg.sender);
    }

    function changeSymbol() public {
        // Проверяем, что голование активно
        require(voteActive);
        // Проверяем, что получили достаточное количество голосов
        require(election.numberOfVotes >= minVotes);
        // Если собрали нужное число голосов, то обновляем имя
        if (election.current >= int256(minVotes) ){
            token.changeName(proposalName);
        }

        // Сбрасываем все переменные для голосования
        election.numberOfVotes = 0;
        election.current = 0;
        voteActive = false;

        token.start();
    }

}
