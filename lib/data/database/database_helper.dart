import 'package:cricket_scoreboard/data/models/match_model.dart';
import 'package:cricket_scoreboard/data/models/player.dart';
import 'package:cricket_scoreboard/data/models/score.dart';
import 'package:cricket_scoreboard/data/models/team.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cricket.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
    CREATE TABLE teams(
      id $idType,
      name $textType UNIQUE
    )
    ''');

    await db.execute('''
    CREATE TABLE players(
      id $idType,
      name $textType UNIQUE,
      age $intType,
      height $realType,
      team_id $intType,
      FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE
    )
    ''');

    await db.execute('''
    CREATE TABLE matches(
      id $idType,
      match_date $textType,
      place $textType,
      total_overs $intType,
      team_a_id $intType,
      team_b_id $intType,
      FOREIGN KEY (team_a_id) REFERENCES teams (id),
      FOREIGN KEY (team_b_id) REFERENCES teams (id)
    )
    ''');

    await db.execute('''
    CREATE TABLE scores(
      id $idType,
      runs $intType,
      balls $intType,
      is_out $intType,
      match_id $intType,
      player_id $intType,
      FOREIGN KEY (match_id) REFERENCES matches (id) ON DELETE CASCADE,
      FOREIGN KEY (player_id) REFERENCES players (id)
    )
    ''');
  }

  // --- TEAM METHODS ---
  Future<void> createTeamWithPlayers(Team team) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      final teamId = await txn.insert('teams', team.toMap());
      for (var player in team.players) {
        await txn.insert('players', player.copyWith(teamId: teamId).toMap());
      }
    });
  }

  Future<List<Team>> getAllTeams() async {
    final db = await instance.database;
    final teamMaps = await db.query('teams', orderBy: 'name');
    if (teamMaps.isEmpty) return [];

    final List<Team> teams = [];
    for (var teamMap in teamMaps) {
      final team = Team.fromMap(teamMap);
      final playerMaps = await db.query(
        'players',
        where: 'team_id = ?',
        whereArgs: [team.id],
      );
      final players = playerMaps.map((p) => Player.fromMap(p)).toList();
      teams.add(team.copyWith(players: players));
    }
    return teams;
  }

  // --- MATCH METHODS ---
  Future<void> createMatch(MatchModel match) async {
    final db = await instance.database;
    await db.insert('matches', match.toMap());
  }

  Future<List<MatchModel>> getAllMatches() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT 
        m.id, m.match_date, m.place, m.total_overs,
        tA.id as team_a_id, tA.name as team_a_name,
        tB.id as team_b_id, tB.name as team_b_name,
        (SELECT COUNT(*) FROM scores WHERE match_id = m.id) > 0 as scores_added
      FROM matches m
      JOIN teams tA ON m.team_a_id = tA.id
      JOIN teams tB ON m.team_b_id = tB.id
      ORDER BY m.match_date DESC
    ''');

    List<MatchModel> matches = [];
    for (var map in result) {
      final teamA = Team(
        id: map['team_a_id'] as int,
        name: map['team_a_name'] as String,
      );
      final teamB = Team(
        id: map['team_b_id'] as int,
        name: map['team_b_name'] as String,
      );
      matches.add(
        MatchModel(
          id: map['id'] as int,
          matchDate: DateTime.parse(map['match_date'] as String),
          place: map['place'] as String,
          totalOvers: map['total_overs'] as int,
          teamA: teamA,
          teamB: teamB,
          scoresAdded: (map['scores_added'] as int) == 1,
        ),
      );
    }
    return matches;
  }

  Future<MatchModel> getMatchDetails(int matchId) async {
    final matches = await getAllMatches();
    final match = matches.firstWhere((m) => m.id == matchId);
    final teamA = (await getAllTeams()).firstWhere(
      (t) => t.id == match.teamA.id,
    );
    final teamB = (await getAllTeams()).firstWhere(
      (t) => t.id == match.teamB.id,
    );
    return MatchModel(
      id: match.id,
      matchDate: match.matchDate,
      place: match.place,
      totalOvers: match.totalOvers,
      teamA: teamA,
      teamB: teamB,
      scoresAdded: match.scoresAdded,
    );
  }

  // --- SCORE METHODS ---
  Future<void> addScoresForMatch(List<Score> scores) async {
    final db = await instance.database;
    final batch = db.batch();
    for (var score in scores) {
      batch.insert('scores', score.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<Score>> getScoresForMatch(int matchId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      '''
      SELECT s.*, p.name, p.age, p.height, p.team_id 
      FROM scores s
      JOIN players p ON s.player_id = p.id
      WHERE s.match_id = ?
    ''',
      [matchId],
    );

    return result.map((map) {
      final player = Player.fromMap(map);
      return Score(
        id: map['id'] as int,
        runs: map['runs'] as int,
        balls: map['balls'] as int,
        isOut: (map['is_out'] as int) == 1,
        matchId: map['match_id'] as int,
        player: player,
      );
    }).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
