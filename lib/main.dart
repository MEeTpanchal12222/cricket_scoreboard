import 'package:cricket_scoreboard/business_logic/match/match_bloc.dart';
import 'package:cricket_scoreboard/business_logic/team/team_bloc.dart';
import 'package:cricket_scoreboard/data/database/database_helper.dart';
import 'package:cricket_scoreboard/presentation/screens/main_navigation_screen.dart';
import 'package:cricket_scoreboard/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

 
  final dbHelper = DatabaseHelper.instance;
  await dbHelper
      .database; 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TeamBloc(dbHelper)..add(LoadTeams())),
        BlocProvider(create: (_) => MatchBloc(dbHelper)..add(LoadMatches())),
      ],
      child: MaterialApp(
        title: 'Cricket Scoreboard',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
