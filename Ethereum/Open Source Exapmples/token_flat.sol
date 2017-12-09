contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}
contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}
contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;
    function DSAuth() public {
        owner = msg.sender;
        LogSetOwner(msg.sender);
    }
    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        LogSetOwner(owner);
    }
    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        LogSetAuthority(authority);
    }
    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }
    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}
contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint              wad,
        bytes             fax
    ) anonymous;
    modifier note {
        bytes32 foo;
        bytes32 bar;
        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }
        LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);
        _;
    }
}
contract DSStop is DSNote, DSAuth {
    bool public stopped;
    modifier stoppable {
        require(!stopped);
        _;
    }
    function stop() public auth note {
        stopped = true;
    }
    function start() public auth note {
        stopped = false;
    }
}
/// base.sol -- базовая реализация ERC20
contract ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf( address who ) public view returns (uint value);
    function allowance( address owner, address spender ) public view returns (uint _allowance);
    function transfer( address to, uint value) public returns (bool ok);
    function transferFrom( address from, address to, uint value) public returns (bool ok);
    function approve( address spender, uint value ) public returns (bool ok);
    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
}
contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }
    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;
    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }
    // Этот известный алгоритм называется "возведение в степень по квадрату"
    // и вычисляет x^n с x с фиксированной точкой и n как обычное беззнаковое число.
    //
    // Сложность -  O(log n), в отличие от O(n) для очевидного повторяющегося умножения.
    //
    // Вот, почему это работает:
    //
    //  Если n четное, то x^n = (x^2)^(n/2).
    //  Если n нечетное,  то x^n = x * x^(n-1),
    //   и применение выражения для четного х дает
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;
        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);
            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}
contract DSTokenBase is ERC20, DSMath {
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;
    function DSTokenBase(uint supply) public {
        _balances[msg.sender] = supply;
        _supply = supply;
    }
    function totalSupply() public view returns (uint) {
        return _supply;
    }
    function balanceOf(address src) public view returns (uint) {
        return _balances[src];
    }
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }
    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }
    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);
        Transfer(src, dst, wad);
        return true;
    }
    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;
        Approval(msg.sender, guy, wad);
        return true;
    }
}
contract DSToken is DSTokenBase(0), DSStop {
    mapping (address => mapping (address => bool)) _trusted;
    bytes32  public  symbol;
    uint256  public  decimals = 18;
    function DSToken(bytes32 symbol_) public {
        symbol = symbol_;
    }
    event Trust(address indexed src, address indexed guy, bool wat);
    event Mint(address indexed guy, uint wad);
    event Burn(address indexed guy, uint wad);
    function trusted(address src, address guy) public view returns (bool) {
        return _trusted[src][guy];
    }
    function trust(address guy, bool wat) public stoppable {
        _trusted[msg.sender][guy] = wat;
        Trust(msg.sender, guy, wat);
    }
    function approve(address guy, uint wad) public stoppable returns (bool) {
        return super.approve(guy, wad);
    }
    function transferFrom(address src, address dst, uint wad)
        public
        stoppable
        returns (bool)
    {
        if (src != msg.sender && !_trusted[src][msg.sender]) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);
        Transfer(src, dst, wad);
        return true;
    }
    function push(address dst, uint wad) public {
        transferFrom(msg.sender, dst, wad);
    }
    function pull(address src, uint wad) public {
        transferFrom(src, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) public {
        transferFrom(src, dst, wad);
    }
    function mint(uint wad) public {
        mint(msg.sender, wad);
    }
    function burn(uint wad) public {
        burn(msg.sender, wad);
    }
    function mint(address guy, uint wad) public auth stoppable {
        _balances[guy] = add(_balances[guy], wad);
        _supply = add(_supply, wad);
        Mint(guy, wad);
    }
    function burn(address guy, uint wad) public auth stoppable {
        if (guy != msg.sender && !_trusted[guy][msg.sender]) {
            _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);
        }
        _balances[guy] = sub(_balances[guy], wad);
        _supply = sub(_supply, wad);
        Burn(guy, wad);
    }
    // Опциональное имя токена
    bytes32   public  name = "";
    function setName(bytes32 name_) public auth {
        name = name_;
    }
}
