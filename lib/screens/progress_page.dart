import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  // Now a map of week -> list of files
  final Map<String, List<File>> _weeklyPhotos = {};
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initNotifications();
    _scheduleWeeklyNotification();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _scheduleWeeklyNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'progress_photo_channel',
      'Progress Photo Reminders',
      channelDescription: 'Reminds you to take your weekly progress photo',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.periodicallyShow(
      0,
      'Time for your progress photo!',
      'Take your weekly progress photo to track your journey.',
      RepeatInterval.weekly,
      notificationDetails,
      androidAllowWhileIdle: false,
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final directory = await getApplicationDocumentsDirectory();
      final weekStart = _getCurrentWeekStart();
      final weekKey = DateFormat('yyyy-MM-dd').format(weekStart);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'progress_${weekKey}_$timestamp.jpg';
      final file = await File(picked.path).copy('${directory.path}/$fileName');
      setState(() {
        _weeklyPhotos.putIfAbsent(weekKey, () => []);
        _weeklyPhotos[weekKey]!.add(file);
      });
    }
  }

  DateTime _getCurrentWeekStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = _getCurrentWeekStart();
    final weekKey = DateFormat('yyyy-MM-dd').format(weekStart);
    final weekLabel = "Week of $weekKey";
    final currentWeekPhotos = _weeklyPhotos[weekKey] ?? [];

    // Get previous weeks sorted (most recent first)
    final previousWeeks = _weeklyPhotos.keys
        .where((k) => k != weekKey)
        .toList()
      ..sort((a, b) => b.compareTo(a));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(weekLabel, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          currentWeekPhotos.isNotEmpty
              ? SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: currentWeekPhotos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, idx) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          currentWeekPhotos[idx],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                )
              : Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.deepPurple.shade100),
                  ),
                  child: const Center(
                    child: Text(
                      'No progress photos for this week.\nTap below to add one!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.deepPurple, fontSize: 18),
                    ),
                  ),
                ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Add Progress Photo'),
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
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Previous Progress Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...previousWeeks.map((week) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Week of $week', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _weeklyPhotos[week]!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _weeklyPhotos[week]![idx],
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}