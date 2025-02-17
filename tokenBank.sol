/*题目#1
编写一个 TokenBank 合约，可以将自己的 Token 存入到 TokenBank， 和从 TokenBank 取出。

TokenBank 有两个方法：


withdraw（）: 用户可以提取自己的之前存入的 token。
在回答框内输入你的代码或者 github 链接。*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
}

contract BaseERC20 is IERC20{
    string public name; 
    string public symbol; 
    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping (address => uint256) balances; 

    mapping (address => mapping (address => uint256)) allowances; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        // write your code here
        // set name,symbol,decimals,totalSupply
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000*(10**decimals);
        balances[msg.sender] = totalSupply;  
    }
//允许任何人查看任何地址的 Token 余额（balanceOf）
    function balanceOf(address _owner) public view returns (uint256 balance) {
        // write your code here
        balance = balances[_owner];

    }
//允许 Token 的所有者将他们的 Token 发送给任何人（transfer）；
//转帐超出余额时抛出异常(require),并显示错误消息 “ERC20: transfer amount exceeds balance”。
    function transfer(address _to, uint256 _value) public returns (bool success) {
        // write your code here
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);  
        return true;   
    }

//允许被授权的地址消费他们被授权的 Token 数量（transferFrom）；
//转帐超出余额时抛出异常(require)，异常信息：“ERC20: transfer amount exceeds balance”
//转帐超出授权数量时抛出异常(require)，异常消息：“ERC20: transfer amount exceeds allowance”。    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // write your code here
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        require(allowances[msg.sender][_from] >= _value, "ERC20: transfer amount exceeds allowance");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[msg.sender][_from] -= _value;
        emit Transfer(_from, _to, _value); 
        return true; 
    }

//允许 Token 的所有者批准某个地址消费他们的一部分Token（approve）

    function approve(address _spender, uint256 _value) public returns (bool success) {
        // write your code here
        allowances[_spender][msg.sender] = _value;
        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

//允许任何人查看一个地址可以从其它账户中转账的代币数量（allowance）

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        // write your code here    
        return allowances[_spender][_owner];

    }
}


contract TokenBank {

    // Mapping to track the deposit balance for each address
    mapping(address => uint) public balances;
    BaseERC20 public erc20Token;

    constructor (address _erc20Token) {
        erc20Token = BaseERC20(_erc20Token);
    }

    //deposit() : 需要记录每个地址的存入数量；
    function deposit(uint amount) external {
        IERC20(erc20Token).transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
    }
    function withdraw(uint amount) external {

        require(balances[msg.sender] >= amount, 'Insufficient token');
        balances[msg.sender] -= amount;
        IERC20(erc20Token).transfer(msg.sender, amount);
    }
    function withdrawAll() external {
        uint amount = balances[msg.sender];
        require(amount > 0, 'Insufficient token');
        balances[msg.sender] = 0;
        IERC20(erc20Token).transfer(msg.sender, amount);
    }    
}