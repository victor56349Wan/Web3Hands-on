// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;
import "ierc20.sol";
contract BaseERC20 is IERC20{
    string public name; 
    string public symbol; 
    uint8 public decimals; 
    uint256 public totalSupply; 


    mapping (address => uint256) balances; 

    mapping (address => mapping (address => uint256)) allowances; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint _totalSupply) {
        // write your code here
        // set name,symbol,decimals,totalSupply
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply*(10**decimals);
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
