import 'package:web3dart/web3dart.dart';

class Player {
  final String playerName;
  final EthereumAddress? playerAddress;
  final bool isPlayer;

  Player({
    required this.playerName,
    required this.isPlayer,
     this.playerAddress,
  });

  factory Player.fromMap(dynamic map) {
    return Player(
      playerName: map[0] as String,
      playerAddress: map[1] as EthereumAddress,


      isPlayer: map[2] as bool,
    );
  }
}
