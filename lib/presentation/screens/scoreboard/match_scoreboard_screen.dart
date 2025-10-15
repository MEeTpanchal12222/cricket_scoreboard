import 'package:cricket_scoreboard/business_logic/scoreboard/scoreboard_bloc.dart';
import 'package:cricket_scoreboard/data/database/database_helper.dart';
import 'package:cricket_scoreboard/data/models/score.dart';
import 'package:cricket_scoreboard/presentation/widgets/responsive_layout_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MatchScoreboardScreen extends StatelessWidget {
  final int matchId;
  const MatchScoreboardScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ScoreboardBloc(DatabaseHelper.instance)..add(LoadScoreboard(matchId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Match Scoreboard')),
        body: BlocBuilder<ScoreboardBloc, ScoreboardState>(
          builder: (context, state) {
            if (state is ScoreboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ScoreboardLoaded) {
              final teamAScore = state.teamAScores.fold(
                0,
                (sum, score) => sum + score.runs,
              );
              final teamBScore = state.teamBScores.fold(
                0,
                (sum, score) => sum + score.runs,
              );

              String summaryText;
              if (teamAScore > teamBScore) {
                summaryText =
                    '${state.match.teamA.name} won by ${teamAScore - teamBScore} runs.';
              } else if (teamBScore > teamAScore) {
                summaryText =
                    '${state.match.teamB.name} won by ${teamBScore - teamAScore} runs.';
              } else {
                summaryText = 'MATCH TIED';
              }

              return ResponsiveLayoutBuilder(
                mobileLayout: _buildMobileLayout(
                  context,
                  state,
                  summaryText,
                  teamAScore,
                  teamBScore,
                ),
                webLayout: _buildWebLayout(
                  context,
                  state,
                  summaryText,
                  teamAScore,
                  teamBScore,
                ),
              );
            }
            if (state is ScoreboardError) {
              return Center(child: Text(state.message));
            }
            return const Center(
              child: Text("No scores added for this match yet."),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    ScoreboardLoaded state,
    String summary,
    int scoreA,
    int scoreB,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSummaryCard(
            context,
            summary,
            state.match.teamA.name,
            state.match.teamB.name,
            scoreA,
            scoreB,
          ),
          const SizedBox(height: 20),
          _buildScorecard(context, state.match.teamA.name, state.teamAScores),
          const SizedBox(height: 20),
          _buildScorecard(context, state.match.teamB.name, state.teamBScores),
        ],
      ),
    );
  }

  Widget _buildWebLayout(
    BuildContext context,
    ScoreboardLoaded state,
    String summary,
    int scoreA,
    int scoreB,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildSummaryCard(
            context,
            summary,
            state.match.teamA.name,
            state.match.teamB.name,
            scoreA,
            scoreB,
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildScorecard(
                  context,
                  state.match.teamA.name,
                  state.teamAScores,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildScorecard(
                  context,
                  state.match.teamB.name,
                  state.teamBScores,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String summary,
    String nameA,
    String nameB,
    int scoreA,
    int scoreB,
  ) {
    final theme = Theme.of(context);
    final isAWinner = scoreA > scoreB;
    final isBWinner = scoreB > scoreA;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              summary,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.amberAccent,
              ),
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '$nameA: $scoreA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isAWinner
                        ? Colors.greenAccent
                        : (isBWinner ? Colors.redAccent : Colors.white),
                  ),
                ),
                Text(
                  '$nameB: $scoreB',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isBWinner
                        ? Colors.greenAccent
                        : (isAWinner ? Colors.redAccent : Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScorecard(
    BuildContext context,
    String teamName,
    List<Score> scores,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                teamName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            DataTable(
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('Player')),
                DataColumn(label: Text('R'), numeric: true),
                DataColumn(label: Text('B'), numeric: true),
                DataColumn(label: Text('Status')),
              ],
              rows: scores
                  .map(
                    (score) => DataRow(
                      cells: [
                        DataCell(Text(score.player.name)),
                        DataCell(Text(score.runs.toString())),
                        DataCell(Text(score.balls.toString())),
                        DataCell(
                          Text(
                            score.isOut ? 'Out' : 'Not Out',
                            style: TextStyle(
                              color: score.isOut
                                  ? Colors.red[300]
                                  : Colors.green[300],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
