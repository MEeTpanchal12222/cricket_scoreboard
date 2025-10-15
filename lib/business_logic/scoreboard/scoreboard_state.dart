
part of 'scoreboard_bloc.dart';
abstract class ScoreboardState extends Equatable {
  const ScoreboardState();
  @override
  List<Object> get props => [];
}

class ScoreboardInitial extends ScoreboardState {}

class ScoreboardLoading extends ScoreboardState {}

class ScoreboardLoaded extends ScoreboardState {
  final MatchModel match;
  final List<Score> teamAScores;
  final List<Score> teamBScores;

  const ScoreboardLoaded({
    required this.match,
    required this.teamAScores,
    required this.teamBScores,
  });

  @override
  List<Object> get props => [match, teamAScores, teamBScores];
}

class ScoreboardOperationSuccess extends ScoreboardState {
  final String message;
  const ScoreboardOperationSuccess(this.message);
}

class ScoreboardError extends ScoreboardState {
  final String message;
  const ScoreboardError(this.message);
}
