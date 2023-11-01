class Player {
  final String playerName;
  final bool isPlayer;
  final bool isWinner;

  Player({
    required this.playerName,
    required this.isPlayer,
    required this.isWinner,
  });

  factory Player.fromMap(dynamic map) {
    return Player(
      playerName: map[0] as String,
      isPlayer: map[1] as bool,
      isWinner: map[2] as bool,
    );
  }
}
