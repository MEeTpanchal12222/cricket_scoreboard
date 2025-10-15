import 'package:cricket_scoreboard/business_logic/match/match_bloc.dart';
import 'package:cricket_scoreboard/data/models/match_model.dart';
import 'package:cricket_scoreboard/presentation/screens/match/create_match_screen.dart';
import 'package:cricket_scoreboard/presentation/screens/scoreboard/add_score_screen.dart';
import 'package:cricket_scoreboard/presentation/screens/scoreboard/match_scoreboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MatchListScreen extends StatelessWidget {
  const MatchListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: BlocConsumer<MatchBloc, MatchState>(
        listener: (context, state) {
          if (state is MatchError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MatchLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MatchLoaded) {
            if (state.matches.isEmpty) {
              return const Center(
                child: Text("No matches created yet. Tap '+' to add one."),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.matches.length,
              itemBuilder: (context, index) {
                final match = state.matches[index];
                return _buildMatchCard(context, match);
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
          ).push(MaterialPageRoute(builder: (_) => const CreateMatchScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, MatchModel match) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${match.teamA.name} vs ${match.teamB.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${DateFormat.yMMMd().format(match.matchDate)} at ${match.place}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!match.scoresAdded)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddScoreScreen(matchId: match.id!),
                            ),
                          )
                          .then((value) {
                            // After returning from AddScoreScreen, reload matches to update the status
                            if (value == true) {
                              context.read<MatchBloc>().add(LoadMatches());
                            }
                          });
                    },
                    child: const Text('ADD SCORE'),
                  ),
                if (match.scoresAdded)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              MatchScoreboardScreen(matchId: match.id!),
                        ),
                      );
                    },
                    child: const Text('VIEW SCOREBOARD'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
