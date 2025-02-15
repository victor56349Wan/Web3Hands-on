// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;
/*
题目#1
在 该挑战 的 Bank 合约基础之上，编写 IBank 接口及BigBank 合约，使其满足 Bank 实现 IBank， BigBank 继承自 Bank ， 同时 BigBank 有附加要求：

要求存款金额 >0.001 ether（用modifier权限控制）
BigBank 合约支持转移管理员
编写一个 Admin 合约， Admin 合约有自己的 Owner ，同时有一个取款函数 adminWithdraw(IBank bank) , adminWithdraw 中会调用 IBank 接口的 withdraw 方法从而把 bank 合约内的资金转移到 Admin 合约地址。

BigBank 和 Admin 合约 部署后，把 BigBank 的管理员转移给 Admin 合约地址，模拟几个用户的存款，然后

Admin 合约的Owner地址调用 adminWithdraw(IBank bank) 把 BigBank 的资金转移到 Admin 地址。
*/
contract Owner {
    address public owner;
    constructor(){
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require (msg.sender == owner, "only owner could call");
        _;
    }
    function transferOwner(address newOwner) external onlyOwner returns (bool){
        owner = newOwner;
        return true;
    }

}

contract Bank is Owner{

    // Mapping to track the deposit balance for each address
    mapping(address => uint) public balances;
    uint constant topN = 3;
    // Array to store the top N depositors
    address[topN] public topNLeaders;

    // Function to withdraw all ETH from this contract to its owner
    function withdraw() external onlyOwner{
        // Check that there is sufficient ETH to withdraw
        require(address(this).balance > 0, 'Insufficient ETH');

        // Transfer all ETH to owner
        payable(Owner.owner).transfer(address(this).balance);
    }
    // Function to withdraw all ETH from this contract contract to specified address
    function withdrawTo(address to) external onlyOwner(){
        // Check that there is sufficient ETH to withdraw
        require(address(this).balance > 0, 'Insufficient ETH');

        // Transfer total ETH to the specified 'to' address
        payable(to).transfer(address(this).balance);
    }
    // Receive function to allow this contract to accept ETH deposits
    receive() external payable virtual{
        // Update the balance for the sender
        balances[msg.sender] += msg.value;

        // Update the leaderboard with the sender's address
        updateTopLeaders(msg.sender);
    }

    // Internal function to update the top 3 depositors in descending order
    function updateTopLeaders(address user) internal {
        // Loop through the top 3 leaderboard
        for (uint8 i = 0; i < uint8(topNLeaders.length); i++) {
            // Check if the current user's balance is greater than the current leader's balance
            if (balances[user] > balances[topNLeaders[i]]) {
                // Found the position for the current user
                // Move members from i to len-2 to position i-1 to len-1
                for (uint8 j = uint8(topNLeaders.length - 1); j > i; j--) {
                    topNLeaders[j] = topNLeaders[j - 1]; // Shift leaders down
                }
                // Insert the user into the correct position in the leaderboard
                topNLeaders[i] = user;   
                break;  // Exit after insertion is done
            }
        }
    }
}

contract BigBank is Bank {

    modifier minAmount(uint amount) {
        require (amount >= 0.001 ether, "too small amount");
        _;
    }
    receive() external payable override minAmount(msg.value){
        // Update the balance for the sender
        balances[msg.sender] += msg.value;

        // Update the leaderboard with the sender's address
        updateTopLeaders(msg.sender);
    }    

}
interface IBank {
    function withdrawTo(address to) external;
}

contract Admin is Owner{
    // withdraw ETH from bank to this contract
    function adminWithdraw(address _bank ) external onlyOwner{
        IBank(_bank).withdrawTo(address(this));
    }
    // withdraw ETH from bank to specified address
    function adminWithdrawTo(address _bank, address _to) external onlyOwner{
        IBank(_bank).withdrawTo(_to);
    }
    // withdraw ETH from this contract to its owner
    function withdrawToOwner() external onlyOwner{
        uint amount = address(this).balance;
        require(amount > 0, 'Insufficient ETH');
        payable(Owner.owner).transfer(amount);
    }
    // allow to receive ETH
    receive() external payable {

    }
}