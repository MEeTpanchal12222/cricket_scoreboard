import 'package:cricket_scoreboard/business_logic/match/match_bloc.dart';
import 'package:cricket_scoreboard/business_logic/team/team_bloc.dart';
import 'package:cricket_scoreboard/data/models/match_model.dart';
import 'package:cricket_scoreboard/data/models/team.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _placeController = TextEditingController();
  final _oversController = TextEditingController();

  Team? _selectedTeamA;
  Team? _selectedTeamB;
  DateTime? _selectedDate;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTeamA == null ||
          _selectedTeamB == null ||
          _selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill all fields"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final match = MatchModel(
        matchDate: _selectedDate!,
        place: _placeController.text,
        totalOvers: int.parse(_oversController.text),
        teamA: _selectedTeamA!,
        teamB: _selectedTeamB!,
      );
      context.read<MatchBloc>().add(AddMatch(match));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat.yMMMd().format(picked);
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _placeController.dispose();
    _oversController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Match')),
      body: BlocListener<MatchBloc, MatchState>(
        listener: (context, state) {
          if (state is MatchOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
          if (state is MatchError) {
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
              
              BlocBuilder<TeamBloc, TeamState>(
                builder: (context, state) {
                  if (state is TeamLoaded) {
                    
                    final teamsForB = state.teams
                        .where((team) => team.id != _selectedTeamA?.id)
                        .toList();

                    return Column(
                      children: [
                        DropdownButtonFormField<Team>(
                          decoration: const InputDecoration(
                            labelText: 'Select Team A',
                          ),
                          initialValue: _selectedTeamA,
                          items: state.teams
                              .map(
                                (team) => DropdownMenuItem(
                                  value: team,
                                  child: Text(team.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() {
                            _selectedTeamA = value;
                          }),
                          validator: (value) =>
                              value == null ? 'Please select a team' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Team>(
                          decoration: const InputDecoration(
                            labelText: 'Select Team B',
                          ),
                          initialValue: _selectedTeamB,
                          items: teamsForB
                              .map(
                                (team) => DropdownMenuItem(
                                  value: team,
                                  child: Text(team.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() {
                            _selectedTeamB = value;
                          }),
                          validator: (value) =>
                              value == null ? 'Please select a team' : null,
                        ),
                      ],
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Match Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) =>
                    value!.isEmpty ? 'Please select a date' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(labelText: 'Match Place'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a place' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _oversController,
                decoration: const InputDecoration(labelText: 'Total Overs'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter total overs' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('CREATE MATCH'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
