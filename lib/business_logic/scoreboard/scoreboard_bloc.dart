import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cricket_scoreboard/data/database/database_helper.dart';
import 'package:cricket_scoreboard/data/models/match_model.dart';
import 'package:cricket_scoreboard/data/models/score.dart';
import 'package:equatable/equatable.dart';

part 'scoreboard_event.dart';
part 'scoreboard_state.dart';

class ScoreboardBloc extends Bloc<ScoreboardEvent, ScoreboardState> {
  final DatabaseHelper _dbHelper;
  ScoreboardBloc(this._dbHelper) : super(ScoreboardInitial()) {
    on<LoadScoreboard>(_onLoadScoreboard);
    on<AddScores>(_onAddScores);
  }

  Future<void> _onLoadScoreboard(
    LoadScoreboard event,
    Emitter<ScoreboardState> emit,
  ) async {
    emit(ScoreboardLoading());
    try {
      final matchDetails = await _dbHelper.getMatchDetails(event.matchId);
      final allScores = await _dbHelper.getScoresForMatch(event.matchId);

      final teamAScores = allScores
          .where((s) => s.player.teamId == matchDetails.teamA.id)
          .toList();
      final teamBScores = allScores
          .where((s) => s.player.teamId == matchDetails.teamB.id)
          .toList();

      emit(
        ScoreboardLoaded(
          match: matchDetails,
          teamAScores: teamAScores,
          teamBScores: teamBScores,
        ),
      );
    } catch (e) {
      emit(ScoreboardError("Failed to load scoreboard: ${e.toString()}"));
    }
  }

  Future<void> _onAddScores(
    AddScores event,
    Emitter<ScoreboardState> emit,
  ) async {
    try {
      await _dbHelper.addScoresForMatch(event.scores);
      emit(const ScoreboardOperationSuccess("Scores added successfully!"));
    } catch (e) {
      emit(ScoreboardError("Failed to add scores: ${e.toString()}"));
    }
  }
}
