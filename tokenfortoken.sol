pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IUniswapRouter {
    function swapExactTokensForTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
    function WETH() external pure returns (address);
    // function approve(address spender, uint value) external returns (bool);

}

interface IUniswapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}


contract SwapToken{
    IUniswapRouter uniswap = IUniswapRouter(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);
    IUniswapFactory factory = IUniswapFactory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    //address public uniswap_factory = address();
    constructor(){
        owner = msg.sender;
    }
    modifier isAdmin(){
        require(msg.sender == owner, "Invoker are not the Owner");
        _;
    }
    address public owner;
    mapping(address =>mapping(address=>uint)) users;
    mapping(address=>uint) usereths;
    event Deposit(address _from,address _to,uint _value);
    event Balance(uint balance);
    function deposit(address _token,uint _amount) public {
        require(_amount>0,"deposit must be greater than 0");
        require(IERC20(_token).totalSupply()>0,"your total lower than amount");
        require(IERC20(_token).balanceOf(msg.sender)>0,"your balance lower than amount");
        emit Balance(IERC20(_token).balanceOf(msg.sender));
        // (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(0x095ea7b3, address(this), _amount));
        // require(success && (data.length == 0 || abi.decode(data, (bool))), "APPROVE_FAILED");
        // //IERC20(_token).approve(msg.sender, _amount);
        (bool success1, bytes memory data1) = _token.call(abi.encodeWithSelector(0x23b872dd, msg.sender, address(this), _amount));
        require(success1 && (data1.length == 0 || abi.decode(data1, (bool))), "TRANSFER_FROM_FAILED");
        //IERC20(_token).transferFrom(msg.sender,address(this),_amount);
        users[msg.sender][_token] = _amount;
        emit Deposit(msg.sender,address(this),_amount);
    }
    function depositETH() public payable{
        require(msg.value>0,"deposit must greater than 0");
        //payable(msg.sender).transfer(address(this),msg.value);
        usereths[msg.sender] = msg.value;
    }
    function withdraw(address _token,uint _amount) public {
        require(_amount<=users[msg.sender][_token],"your deposit balance lower than amount");
        // IERC20(_token).approve(msg.sender, _amount);
        IERC20(_token).transferFrom(address(this),msg.sender,_amount);
        users[msg.sender][_token] = users[msg.sender][_token] - _amount;
    }
    function withdrawETH(uint _amount) public{
        require(_amount<=usereths[msg.sender],"your deposit balance lower than amount");
        payable(msg.sender).transfer(_amount);
        usereths[msg.sender] = usereths[msg.sender] - _amount;
    }
    //用以太坊买别的币
    function swapExtractTokensForTokens(uint amountIn,uint amountOutMin,address _token1,address _token2,address to,uint deadline) isAdmin external payable{
        //uniswap.approve(_token1,amountIn);
        //  IERC20(_token1).approve(msg.sender,amountIn);
        address pair = factory.getPair(_token1,_token2);
        require(pair != address(0x0000000000000000000000000000000000000000));
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapPair(pair).getReserves();
        require(reserve0!=0);
        require(reserve1!=0);
        address[] memory path = new address[](2);
        path[0] = _token1;
        path[1] = _token2;
        uniswap.swapExactTokensForTokens(amountIn,amountOutMin,path,to,deadline);
    }

}