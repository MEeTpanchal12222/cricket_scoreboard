import 'package:cricket_scoreboard/data/models/player.dart';
import 'package:equatable/equatable.dart';

class Team extends Equatable {
  final int? id;
  final String name;
  final List<Player> players;

  const Team({this.id, required this.name, this.players = const []});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(id: map['id']?.toInt(), name: map['name'] ?? '');
  }

  Team copyWith({int? id, String? name, List<Player>? players}) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      players: players ?? this.players,
    );
  }

  @override
  List<Object?> get props => [id, name, players];
}
