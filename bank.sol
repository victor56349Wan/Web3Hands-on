// SPDX-License-Identifier: MIT

/*
 * @title Bank Contract
 * @dev This contract allows users to deposit ETH and keeps track of their balances.
 * It also maintains a leaderboard for the top 3 depositors by balance.
 * The contract allows only the admin (contract creator) to withdraw all ETH.
 *
 * Key features:
 * - Users can deposit ETH via MetaMask.
 * - The contract records the ETH balance for each address.
 * - It keeps a leaderboard of the top 3 addresses with the highest balances.
 * - Only the admin can withdraw the total ETH from the contract.
 */

pragma solidity >=0.8.28;

contract Bank {

    // Mapping to track the deposit balance for each address
    mapping(address => uint) public balances;
    uint constant topN = 3;
    // Array to store the top N depositors
    address[topN] public topNLeaders;

    // Admin address (contract creator by default) with the ability to withdraw funds
    address public admin;

    // Constructor that sets the admin as the contract creator
    constructor() {
        admin = msg.sender;
    }

    // Function to withdraw all ETH from the contract
    function withdraw() public {
        // Ensure that only the admin can withdraw funds
        require(msg.sender == admin, 'Only owner could withdraw');
        // Check that there is sufficient ETH to withdraw
        
        require(address(this).balance > 0, 'Insufficient ETH');

        // Transfer total ETH to the admin
        payable(admin).transfer(address(this).balance);
    }

    // Receive function to allow the contract to accept ETH deposits
    receive() external payable {
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
