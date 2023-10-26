// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.21;

contract Lottery {
    address public manager;
    address[] public players;

    constructor() {
        manager = msg.sender;
    }

    // Function to enter the lottery
    function enter() public payable validateAmount {
        require(players.length < 3, "Maximum 3 players allowed");
        players.push(msg.sender);
    }

    // Function to pick a winner
    function pickWinner() public restricted {
        require(players.length > 0, "No players to pick a winner");
        address winner = players[random() % players.length];
        uint balance = address(this).balance;
        payable(winner).transfer(balance);
        players = new address[](0); // Reset the players array
    }

    // Function to get the current players
    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    // Modifier to restrict access to the manager
    modifier restricted() {
        require(
            msg.sender == manager,
            "Only the manager can call this function"
        );
        _;
    }
    modifier validateAmount() {
        require(msg.value == 0.1 ether, "Minimum contribution is 1 ether");
        _;
    }

    // Function to generate a pseudo-random number based on the block's timestamp
    function random() private view returns (uint) {
        return
            uint(
                keccak256(abi.encodePacked(block.timestamp, players, manager))
            );
    }

    // Receive function to accept Ether
    receive() external payable {
        // This function allows the contract to accept Ether without a specific function call.
    }
}
