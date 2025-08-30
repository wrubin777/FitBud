import 'package:flutter/material.dart';

class FitnessGoalsPage extends StatefulWidget {
  const FitnessGoalsPage({super.key});

  @override
  State<FitnessGoalsPage> createState() => _FitnessGoalsPageState();
}

class _FitnessGoalsPageState extends State<FitnessGoalsPage> {
  final List<String> _selectedGoals = [];
  final List<String> _goals = [
    'Lose Weight',
    'Build Muscle',
    'Improve Endurance',
    'Increase Flexibility',
    'General Health',
    'Sports Performance',
    'Rehabilitation',
  ];

  void _toggleGoal(String goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else if (_selectedGoals.length < 3) {
        _selectedGoals.add(goal);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitness Goals')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What are your fitness goals?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Select up to 3', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: _goals.map((goal) {
                  final selected = _selectedGoals.contains(goal);
                  return Card(
                    elevation: selected ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: selected ? Theme.of(context).primaryColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      title: Text(goal),
                      trailing: selected
                          ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                          : Icon(Icons.circle_outlined, color: Colors.grey),
                      onTap: () => _toggleGoal(goal),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _selectedGoals.isNotEmpty
                    ? () => Navigator.pushReplacementNamed(context, '/workoutfrequency')
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}