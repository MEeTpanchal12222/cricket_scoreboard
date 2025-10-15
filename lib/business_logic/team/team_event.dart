part of 'team_bloc.dart';

abstract class TeamEvent extends Equatable {
  const TeamEvent();
  @override
  List<Object> get props => [];
}

class LoadTeams extends TeamEvent {}

class AddTeam extends TeamEvent {
  final Team team;
  const AddTeam(this.team);

  @override
  List<Object> get props => [team];
}
