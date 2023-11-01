class Player {
  final String playerName;
  final bool isPlayer;
  final bool isWinner;

  Player({
    required this.playerName,
    required this.isPlayer,
    required this.isWinner,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      playerName: map['playerName'] as String,
      isPlayer: map['isPlayer'] as bool,
      isWinner: map['isWinner'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playerName': playerName,
      'isPlayer': isPlayer,
      'isWinner': isWinner,
    };
  }
}
