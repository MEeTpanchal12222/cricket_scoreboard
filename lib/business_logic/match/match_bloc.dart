import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cricket_scoreboard/data/database/database_helper.dart';
import 'package:cricket_scoreboard/data/models/match_model.dart';
import 'package:equatable/equatable.dart';

part 'match_event.dart';
part 'match_state.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final DatabaseHelper _dbHelper;
  MatchBloc(this._dbHelper) : super(MatchInitial()) {
    on<LoadMatches>(_onLoadMatches);
    on<AddMatch>(_onAddMatch);
  }

  Future<void> _onLoadMatches(
    LoadMatches event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    try {
      final matches = await _dbHelper.getAllMatches();
      emit(MatchLoaded(matches));
    } catch (e) {
      emit(MatchError("Failed to load matches: ${e.toString()}"));
    }
  }

  Future<void> _onAddMatch(AddMatch event, Emitter<MatchState> emit) async {
    try {
      await _dbHelper.createMatch(event.match);
      emit(const MatchOperationSuccess("Match created successfully!"));
      add(LoadMatches());
    } catch (e) {
      emit(MatchError("Failed to create match: ${e.toString()}"));
    }
  }
}
