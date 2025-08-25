import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final Map<String, File> _weeklyPhotos = {};
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

    // Schedule for next Monday at 10:00 AM
    DateTime now = DateTime.now();
    DateTime nextMonday = now.add(Duration(days: (8 - now.weekday) % 7));
    DateTime notificationTime = DateTime(nextMonday.year, nextMonday.month, nextMonday.day, 10);

    final tz.TZDateTime tzNotificationTime = tz.TZDateTime.from(notificationTime, tz.local);

    await _notificationsPlugin.zonedSchedule(
      0,
      'Time for your progress photo!',
      'Take your weekly progress photo to track your journey.',
      tzNotificationTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final directory = await getApplicationDocumentsDirectory();
      final weekStart = _getCurrentWeekStart();
      final fileName = 'progress_${DateFormat('yyyyMMdd').format(weekStart)}.jpg';
      final file = await File(picked.path).copy('${directory.path}/$fileName');
      setState(() {
        _weeklyPhotos[DateFormat('yyyy-MM-dd').format(weekStart)] = file;
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
    final weekLabel = "Week of ${DateFormat('yyyy-MM-dd').format(weekStart)}";
    final photo = _weeklyPhotos[DateFormat('yyyy-MM-dd').format(weekStart)];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(weekLabel, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          photo != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(photo, height: 250, width: double.infinity, fit: BoxFit.cover),
                )
              : Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.deepPurple.shade100),
                  ),
                  child: const Center(
                    child: Text(
                      'No progress photo for this week.\nTap below to add one!',
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
          ..._weeklyPhotos.entries
              .where((entry) => entry.key != DateFormat('yyyy-MM-dd').format(weekStart))
              .map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(entry.value, width: 50, height: 50, fit: BoxFit.cover),
                      ),
                      title: Text('Week of ${entry.key}'),
                    ),
                  )),
        ],
      ),
    );
  }
}