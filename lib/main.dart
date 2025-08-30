import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/theme_provider.dart'; 
import 'screens/main_page.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'screens/post_register_splash.dart';
import 'screens/personal_info_page.dart';
import 'screens/fitness_goals_page.dart';
import 'screens/workout_frequency_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> requestNotificationPermission() async {
  if (Platform.isAndroid) {
    await Permission.notification.request();
  } else if (Platform.isIOS) {
    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Fitness App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        brightness: Brightness.dark,
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/postregistersplash': (context) => const PostRegisterSplash(),
        '/personalinfo': (context) => const PersonalInfoPage(),
        '/fitnessgoals': (context) => const FitnessGoalsPage(),
        '/workoutfrequency': (context) => const WorkoutFrequencyPage(),
        '/main': (context) => const MainPage(),
      },
    );
  }
}
