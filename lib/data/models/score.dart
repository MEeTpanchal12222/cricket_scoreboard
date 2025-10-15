import 'package:cricket_scoreboard/data/models/player.dart';
import 'package:equatable/equatable.dart';

class Score extends Equatable {
  final int? id;
  final int runs;
  final int balls;
  final bool isOut;
  final int matchId;
  final Player player;

  const Score({
    this.id,
    required this.runs,
    required this.balls,
    required this.isOut,
    required this.matchId,
    required this.player,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'runs': runs,
      'balls': balls,
      'is_out': isOut ? 1 : 0,
      'match_id': matchId,
      'player_id': player.id,
    };
  }

  @override
  List<Object?> get props => [id, runs, balls, isOut, matchId, player];
}
