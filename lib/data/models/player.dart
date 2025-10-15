import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final int? id;
  final String name;
  final int age;
  final double height;
  final int? teamId;

  const Player({
    this.id,
    required this.name,
    required this.age,
    required this.height,
    this.teamId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'height': height,
      'team_id': teamId,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      age: map['age']?.toInt() ?? 0,
      height: map['height']?.toDouble() ?? 0.0,
      teamId: map['team_id']?.toInt(),
    );
  }

  Player copyWith({
    int? id,
    String? name,
    int? age,
    double? height,
    int? teamId,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      teamId: teamId ?? this.teamId,
    );
  }

  @override
  List<Object?> get props => [id, name, age, height, teamId];
}
