import 'package:flutter/material.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  final List<Map<String, String>> _workouts = [];

  void _showAddWorkoutDialog() async {
    final titleController = TextEditingController();
    final hoursController = TextEditingController();
    final minutesController = TextEditingController();
    DateTime? selectedDate;

    Map<String, String>? newWorkout;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Workout'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Workout Name',
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: TextField(
                            controller: hoursController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Hours',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: TextField(
                            controller: minutesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Minutes',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDate == null
                                ? 'No date chosen'
                                : 'Date: ${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final hours = int.tryParse(hoursController.text) ?? 0;
                    final minutes = int.tryParse(minutesController.text) ?? 0;
                    final date = selectedDate != null
                        ? '${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                        : '';
                    if (title.isNotEmpty && (hours > 0 || minutes > 0) && date.isNotEmpty) {
                      newWorkout = {
                        'title': title,
                        'duration': '${hours > 0 ? '$hours h ' : ''}${minutes > 0 ? '$minutes min' : ''}'.trim(),
                        'date': date,
                      };
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (newWorkout != null) {
      setState(() {
        _workouts.add(newWorkout!);
      });
    }
  }

  // Helper to group workouts by week
  Map<String, List<Map<String, String>>> _groupWorkoutsByWeek(List<Map<String, String>> workouts) {
    Map<String, List<Map<String, String>>> grouped = {};
    DateTime now = DateTime.now();
    DateTime thisWeekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    DateTime nextWeekStart = thisWeekStart.add(const Duration(days: 7));

    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    for (var workout in workouts) {
      if (workout['date'] == null) continue;
      DateTime date = DateTime.parse(workout['date']!);
      DateTime weekStart = DateTime(date.year, date.month, date.day).subtract(Duration(days: date.weekday - 1));
      String weekLabel;
      if (isSameDay(weekStart, thisWeekStart)) {
        weekLabel = "This Week";
      } else if (isSameDay(weekStart, nextWeekStart)) {
        weekLabel = "Next Week";
      } else if (weekStart.isAfter(nextWeekStart)) {
        weekLabel = "Later On";
      } else {
        weekLabel = "Past Workouts";
      }
      grouped.putIfAbsent(weekLabel, () => []).add(workout);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedWorkouts = _groupWorkoutsByWeek(_workouts);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workout Tracker',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddWorkoutDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Workout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _workouts.isEmpty
                ? Center(
                    child: Text(
                      "Add your workouts here!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurple[200],
                        fontFamily: 'Montserrat',
                        letterSpacing: 1.2,
                      ),
                    ),
                  )
                : ListView(
                    children: groupedWorkouts.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          ...entry.value.map((workout) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _WorkoutCard(
                                  title: workout['title'] ?? '',
                                  duration: workout['duration'] ?? '',
                                  date: workout['date'] ?? '',
                                ),
                              )),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final String title;
  final String duration;
  final String date;

  const _WorkoutCard({
    required this.title,
    required this.duration,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.fitness_center, color: Colors.deepPurple, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text('$duration • $date'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Implement workout details navigation
        },
      )
    );
  }
}