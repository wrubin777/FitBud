import 'package:flutter/material.dart';

class WorkoutFrequencyPage extends StatefulWidget {
  const WorkoutFrequencyPage({super.key});

  @override
  State<WorkoutFrequencyPage> createState() => _WorkoutFrequencyPageState();
}

class _WorkoutFrequencyPageState extends State<WorkoutFrequencyPage> {
  int _selectedDays = 0;
  final List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Map<int, String> _frequencyDescriptions = {
    0: 'Starting your fitness journey',
    1: 'Getting into the habit',
    2: 'Building consistency',
    3: 'Creating a solid routine',
    4: 'Committed to fitness',
    5: 'Dedicated fitness enthusiast',
    6: 'Advanced training regime',
    7: 'Elite fitness level',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Frequency')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How often do you plan to workout?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Select the number of days per week', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text('$_selectedDays', style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  const Text('days per week', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(_frequencyDescriptions[_selectedDays] ?? '', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List.generate(7, (index) {
                  final isSelected = _selectedDays > index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDays = index + 1),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _weekdays[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Spacer(),
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _selectedDays = 0),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset selection'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _selectedDays > 0
                    ? () => Navigator.pushReplacementNamed(context, '/main')
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Finish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}