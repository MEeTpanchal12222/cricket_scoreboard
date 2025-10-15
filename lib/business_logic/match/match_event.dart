part of 'match_bloc.dart';

abstract class MatchEvent extends Equatable {
  const MatchEvent();
  @override
  List<Object> get props => [];
}

class LoadMatches extends MatchEvent {}

class AddMatch extends MatchEvent {
  final MatchModel match;
  const AddMatch(this.match);

  @override
  List<Object> get props => [match];
}
