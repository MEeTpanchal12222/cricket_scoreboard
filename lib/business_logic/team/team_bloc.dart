import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cricket_scoreboard/data/database/database_helper.dart';
import 'package:cricket_scoreboard/data/models/team.dart';
import 'package:equatable/equatable.dart';

part 'team_event.dart';
part 'team_state.dart';

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final DatabaseHelper _dbHelper;

  TeamBloc(this._dbHelper) : super(TeamInitial()) {
    on<LoadTeams>(_onLoadTeams);
    on<AddTeam>(_onAddTeam);
  }

  Future<void> _onLoadTeams(LoadTeams event, Emitter<TeamState> emit) async {
    emit(TeamLoading());
    try {
      final teams = await _dbHelper.getAllTeams();
      emit(TeamLoaded(teams));
    } catch (e) {
      emit(TeamError("Failed to load teams: ${e.toString()}"));
    }
  }

  Future<void> _onAddTeam(AddTeam event, Emitter<TeamState> emit) async {
    try {
      await _dbHelper.createTeamWithPlayers(event.team);
      emit(const TeamOperationSuccess("Team created successfully!"));
      add(LoadTeams()); // Reload teams to update the list
    } catch (e) {
      emit(
        TeamError(
          "Failed to create team. Team or player name might already exist.",
        ),
      );
    }
  }
}
