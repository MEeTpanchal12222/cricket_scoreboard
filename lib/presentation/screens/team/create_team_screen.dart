import 'package:cricket_scoreboard/business_logic/team/team_bloc.dart';
import 'package:cricket_scoreboard/data/models/player.dart';
import 'package:cricket_scoreboard/data/models/team.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final List<TextEditingController> _playerNameControllers = List.generate(
    11,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _playerAgeControllers = List.generate(
    11,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _playerHeightControllers = List.generate(
    11,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    _teamNameController.dispose();
    for (var i = 0; i < 11; i++) {
      _playerNameControllers[i].dispose();
      _playerAgeControllers[i].dispose();
      _playerHeightControllers[i].dispose();
    }
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final List<Player> players = [];
      for (int i = 0; i < 11; i++) {
        players.add(
          Player(
            name: _playerNameControllers[i].text,
            age: int.parse(_playerAgeControllers[i].text),
            height: double.parse(_playerHeightControllers[i].text),
          ),
        );
      }
      final team = Team(name: _teamNameController.text, players: players);
      context.read<TeamBloc>().add(AddTeam(team));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Team')),
      body: BlocListener<TeamBloc, TeamState>(
        listener: (context, state) {
          if (state is TeamOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
          if (state is TeamError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                "Team Details",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teamNameController,
                decoration: const InputDecoration(labelText: 'Team Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a team name' : null,
              ),
              const SizedBox(height: 24),
              Text(
                "Player Details (11 Players)",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(height: 20),
              ...List.generate(11, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Player ${index + 1}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _playerNameControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Player Name',
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _playerAgeControllers[index],
                                  decoration: const InputDecoration(
                                    labelText: 'Age',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) =>
                                      value!.isEmpty ? 'Req' : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _playerHeightControllers[index],
                                  decoration: const InputDecoration(
                                    labelText: 'Height (cm)',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) =>
                                      value!.isEmpty ? 'Req' : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('CREATE TEAM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
