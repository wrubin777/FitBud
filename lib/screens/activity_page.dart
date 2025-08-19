import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _ActivityStat(label: 'Steps', value: '8,542'),
              _ActivityStat(label: 'Distance', value: '6.2 km'),
              _ActivityStat(label: 'Calories', value: '420'),
              _ActivityStat(label: 'Active', value: '1h 12m'),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Today\'s Route', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepPurple),
            ),
            child: const Center(
              child: Text(
                '[Map Placeholder]',
                style: TextStyle(color: Colors.deepPurple, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityStat extends StatelessWidget {
  final String label;
  final String value;
  const _ActivityStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }
}