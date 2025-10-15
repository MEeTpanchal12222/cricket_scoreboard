import 'package:cricket_scoreboard/business_logic/scoreboard/scoreboard_bloc.dart';
import 'package:cricket_scoreboard/data/database/database_helper.dart';
import 'package:cricket_scoreboard/data/models/player.dart';
import 'package:cricket_scoreboard/data/models/score.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddScoreScreen extends StatelessWidget {
  final int matchId;
  const AddScoreScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ScoreboardBloc(DatabaseHelper.instance)..add(LoadScoreboard(matchId)),
      child: Scaffold(
        appBar: AppBar(title: const Text("Add Player Scores")),
        body: BlocConsumer<ScoreboardBloc, ScoreboardState>(
          listener: (context, state) {
            if (state is ScoreboardOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              // Pop with a 'true' value to signal the previous screen to reload
              Navigator.of(context).pop(true);
            }
            if (state is ScoreboardError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ScoreboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ScoreboardLoaded) {
              return ScoreForm(matchId: matchId, state: state);
            }
            return const Center(child: Text("Error loading match details."));
          },
        ),
      ),
    );
  }
}

class ScoreForm extends StatefulWidget {
  final int matchId;
  final ScoreboardLoaded state;
  const ScoreForm({super.key, required this.matchId, required this.state});

  @override
  State<ScoreForm> createState() => _ScoreFormState();
}

class _ScoreFormState extends State<ScoreForm> {
  late final List<TextEditingController> _runControllers;
  late final List<TextEditingController> _ballControllers;
  late final List<bool> _isOutStatus;
  late final List<Player> _allPlayers;

  @override
  void initState() {
    super.initState();
    _allPlayers = [
      ...widget.state.match.teamA.players,
      ...widget.state.match.teamB.players,
    ];
    _runControllers = List.generate(
      _allPlayers.length,
      (_) => TextEditingController(text: '0'),
    );
    _ballControllers = List.generate(
      _allPlayers.length,
      (_) => TextEditingController(text: '0'),
    );
    _isOutStatus = List.generate(_allPlayers.length, (_) => false);
  }

  @override
  void dispose() {
    for (var c in _runControllers) {
      c.dispose();
    }
    for (var c in _ballControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _submitScores() {
    final List<Score> scores = [];
    for (int i = 0; i < _allPlayers.length; i++) {
      scores.add(
        Score(
          runs: int.tryParse(_runControllers[i].text) ?? 0,
          balls: int.tryParse(_ballControllers[i].text) ?? 0,
          isOut: _isOutStatus[i],
          matchId: widget.matchId,
          player: _allPlayers[i],
        ),
      );
    }
    context.read<ScoreboardBloc>().add(AddScores(scores));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildTeamSection(
          context,
          widget.state.match.teamA.name,
          widget.state.match.teamA.players,
          0,
        ),
        const SizedBox(height: 24),
        _buildTeamSection(
          context,
          widget.state.match.teamB.name,
          widget.state.match.teamB.players,
          11,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _submitScores,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('SUBMIT SCORES'),
        ),
      ],
    );
  }

  Widget _buildTeamSection(
    BuildContext context,
    String teamName,
    List<Player> players,
    int startIndex,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(teamName, style: Theme.of(context).textTheme.headlineSmall),
        const Divider(height: 20),
        ...List.generate(players.length, (index) {
          final playerIndex = startIndex + index;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    players[index].name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _runControllers[playerIndex],
                          decoration: const InputDecoration(labelText: 'Runs'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _ballControllers[playerIndex],
                          decoration: const InputDecoration(labelText: 'Balls'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    title: const Text("Is Out?"),
                    value: _isOutStatus[playerIndex],
                    onChanged: (value) =>
                        setState(() => _isOutStatus[playerIndex] = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
