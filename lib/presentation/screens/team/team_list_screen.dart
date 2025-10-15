import 'package:cricket_scoreboard/business_logic/team/team_bloc.dart';
import 'package:cricket_scoreboard/presentation/screens/team/create_team_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeamListScreen extends StatelessWidget {
  const TeamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teams')),
      body: BlocConsumer<TeamBloc, TeamState>(
        listener: (context, state) {
          if (state is TeamError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TeamLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TeamLoaded) {
            if (state.teams.isEmpty) {
              return const Center(
                child: Text("No teams created yet. Tap '+' to add one."),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.teams.length,
              itemBuilder: (context, index) {
                final team = state.teams[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ExpansionTile(
                    title: Text(
                      team.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    children: team.players
                        .map(
                          (player) => ListTile(
                            title: Text(player.name),
                            subtitle: Text(
                              "Age: ${player.age}, Height: ${player.height} cm",
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            );
          }
          return const Center(child: Text("Something went wrong."));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CreateTeamScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
