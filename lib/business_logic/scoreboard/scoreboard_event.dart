part of 'scoreboard_bloc.dart';

abstract class ScoreboardEvent extends Equatable {
  const ScoreboardEvent();
  @override
  List<Object> get props => [];
}

class LoadScoreboard extends ScoreboardEvent {
  final int matchId;
  const LoadScoreboard(this.matchId);

  @override
  List<Object> get props => [matchId];
}

class AddScores extends ScoreboardEvent {
  final List<Score> scores;
  const AddScores(this.scores);

  @override
  List<Object> get props => [scores];
}
