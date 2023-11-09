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
        address playerAddress;
        bool isPlayer;

        
    }

    address public immutable manager;
    address public  winner;
    mapping(address => Player) public players;
    address[] addresses;


    // Define an event for when a player enters the lottery
    event PlayerEntered(Player);

    // Define an event for when a winner is picked
    event WinnerPicked(Player, uint prizeAmount);

    constructor() {
        manager = msg.sender;
    }

    function enter(string memory playerName) public payable validateAmount {
        require(!players[msg.sender].isPlayer, "You are already a player");

        players[msg.sender] = Player(playerName,msg.sender, true);
        addresses.push(msg.sender);


        // Emit the PlayerEntered event when a player enters the lottery
        emit PlayerEntered(players[msg.sender]);
    }

    function pickWinner() public restricted {
        require(
            addresses.length >= 3,
            "At least 3 players required to pick a winner"
        );

        
        uint index = uint(
            keccak256(abi.encodePacked(block.timestamp, addresses))
        ) % (addresses.length);

        winner = addresses[index];

        uint balance = address(this).balance;

        // Transfer the prize amount to the winner
        payable(winner).transfer(balance);



        // Emit the WinnerPicked event when a winner is picked
        emit WinnerPicked(players[winner], balance);

        // Reset the players and addresses array
        delete addresses;
     
    }

    modifier restricted() {
        require(
            msg.sender == manager,
            "Only the manager can call this function"
        );
        _;
    }

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

    function getTotalMapping() public view returns (Player[] memory) {
        uint256 length = addresses.length;
        Player[] memory playerData = new Player[](length);
        for (uint256 i = 0; i < length; i++) {
            playerData[i] = players[addresses[i]];
        }
        return playerData;
    }

  
}
