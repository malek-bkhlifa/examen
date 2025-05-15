class Score {
  final int? id; // Added ID field
  final String playerName;
  final int score;
  final int time; // in seconds

  Score({
    this.id, // Optional ID (will be null for new scores)
    required this.playerName,
    required this.score,
    required this.time,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      id: json['id'],
      playerName: json['playerName'],
      score: json['score'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerName': playerName,
      'score': score,
      'time': time,
    };
  }
}