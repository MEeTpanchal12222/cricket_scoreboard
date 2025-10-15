import 'package:cricket_scoreboard/data/models/team.dart';
import 'package:equatable/equatable.dart';

class MatchModel extends Equatable {
  final int? id;
  final DateTime matchDate;
  final String place;
  final int totalOvers;
  final Team teamA;
  final Team teamB;
  final bool scoresAdded;

  const MatchModel({
    this.id,
    required this.matchDate,
    required this.place,
    required this.totalOvers,
    required this.teamA,
    required this.teamB,
    this.scoresAdded = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'match_date': matchDate.toIso8601String(),
      'place': place,
      'total_overs': totalOvers,
      'team_a_id': teamA.id,
      'team_b_id': teamB.id,
    };
  }

  @override
  List<Object?> get props => [
    id,
    matchDate,
    place,
    totalOvers,
    teamA,
    teamB,
    scoresAdded,
  ];
}
