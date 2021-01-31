class Game {
  final String id;
  final bool isFull;
  // final bool isFinsh;
  // final int maxPlayer;
  // final int level;
  // final String players;
  // final String createSocetID;
  Game(this.id, this.isFull);

  Game.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        isFull = json['isFull'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'isFull': isFull,
      };
}
