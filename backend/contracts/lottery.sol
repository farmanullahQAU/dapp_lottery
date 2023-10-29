// contract Lottery {
//     address public manager;
//     address[] public players;

//     constructor() {
//         manager = msg.sender;
//     }

//     // Function to enter the lottery
//     function enter() public payable validateAmount {
//         require(players.length < 3, "Maximum 3 players allowed");
//         require(!isPlayer(msg.sender), "Player already entered");
//         players.push(msg.sender);
//     }
// function isPlayer(address player) public view returns (bool) {
//     for (uint i = 0; i < players.length; i++) {
//         if (players[i] == player) {
//             return true;
//         }
//     }
//     return false;
// }
//     // Function to pick a winner
//     function pickWinner() public restricted {
//         require(players.length > 0, "No players to pick a winner");
//         address winner = players[random() % players.length];
//         uint balance = address(this).balance;
//         payable(winner).transfer(balance);
//         players = new address[](0); // Reset the players array
//     }

//     // Function to get the current players
//     function getPlayers() public view returns (address[] memory) {
//         return players;
//     }

//     // Modifier to restrict access to the manager
//     modifier restricted() {
//         require(
//             msg.sender == manager,
//             "Only the manager can call this function"
//         );
//         _;
//     }
//     modifier validateAmount() {
//         require(msg.value == 0.1 ether, "Minimum contribution is 1 ether");
//         _;
//     }

//     // Function to generate a pseudo-random number based on the block's timestamp
//     function random() private view returns (uint) {
//         return
//             uint(
//                 keccak256(abi.encodePacked(block.timestamp, players, manager))
//             );
//     }

//     // Receive function to accept Ether
//     receive() external payable {
//         // This function allows the contract to accept Ether without a specific function call.
//     }
// }
// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.8.21;

contract Lottery {
    struct Player {
        string playerName;
        bool isPlayer;
        bool isWinner;
    }
    address public immutable manager;
    mapping(address => Player) public players;
    address[] addresses;

    uint public totalPlayers;

    constructor() {
        manager = msg.sender;
    }

    // Function to enter the lottery
    function enter(string memory playerName) public payable validateAmount {
        require(!players[msg.sender].isPlayer, "Already Player");

        players[msg.sender] = Player(playerName, true, false);
        addresses.push(msg.sender);

        totalPlayers += 1;
    }

    // Function to pick a winner
    function pickWinner() public restricted {
        require(totalPlayers == 3, "Atleast 3 players to pick winner");
        // Generate a pseudo-random number based on the block's timestamp
        uint index = uint(
            keccak256(abi.encodePacked(block.timestamp, addresses))
        ) % totalPlayers;

        address winnerAddress = addresses[index];

        uint balance = address(this).balance;
        payable(winnerAddress).transfer(balance);

        players[winnerAddress].isWinner = true;
    }

    // Modifier to restrict access to the manager
    modifier restricted() {
        require(
            msg.sender == manager,
            "Only the manager can call this function"
        );
        _;
    }

    // Modifier to validate the amount
    modifier validateAmount() {
        require(
            msg.value >= 0.001 ether,
            "Minimum contribution is 0.001 ether"
        );
        _;
    }

    function totalBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Function to get the total mapping
    function getTotalMapping() public view returns (Player[] memory) {
        uint256 length = addresses.length;
        Player[] memory playerData = new Player[](length);
        for (uint256 i = 0; i < length; i++) {
            playerData[i] = players[addresses[i]];
        }
        return playerData;
    }
}
