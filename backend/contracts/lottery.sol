
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
    require(addresses.length >= 3, "At least 3 players required to pick a winner");

   
    uint index = uint(keccak256(abi.encodePacked(blockhash(block.number - 1)))) % addresses.length;

    winner = addresses[index];

    uint balance = address(this).balance;

    // Transfer the prize amount to the winner
    payable(winner).transfer(balance);

    // Emit the WinnerPicked event when a winner is picked
    emit WinnerPicked(players[winner], balance);

    // Reset the players and addresses array
    resetPlayers();
}
  function resetPlayers() public  {

 for (uint256 i = 0; i < addresses.length; i++) {
           delete players[addresses[i]];
          

        }
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
