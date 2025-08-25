import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  String language = 'English';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        const SizedBox(height: 24),
        // Profile Section
        ListTile(
          leading: const Icon(Icons.person, color: Colors.deepPurple),
          title: const Text('Your Profile'),
          onTap: () {
            // TODO: Implement profile page navigation
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.deepPurple),
          title: const Text('Sign Out'),
          onTap: () {
            // TODO: Implement sign out logic
          },
        ),
        const Divider(height: 32),
        const Text(
          'Preferences',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        SwitchListTile(
          title: const Text('Enable Notifications'),
          value: notificationsEnabled,
          onChanged: (val) {
            setState(() {
              notificationsEnabled = val;
            });
          },
          secondary: const Icon(Icons.notifications),
        ),
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: Provider.of<ThemeProvider>(context).isDarkMode,
          onChanged: (val) {
            Provider.of<ThemeProvider>(context, listen: false).toggleDarkMode(val);
          },
          secondary: const Icon(Icons.dark_mode),
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          trailing: DropdownButton<String>(
            value: language,
            items: const [
              DropdownMenuItem(value: 'English', child: Text('English')),
              DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
              DropdownMenuItem(value: 'French', child: Text('French')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  language = val;
                });
              }
            },
          ),
        ),
        const Divider(height: 32),
        const Text(
          'Goals',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        ListTile(
          leading: const Icon(Icons.directions_walk),
          title: const Text('Daily Step Goal'),
          subtitle: const Text('[Placeholder: Set your daily step goal]'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.flag),
          title: const Text('Activity Goals'),
          subtitle: const Text('[Placeholder: Set your activity goals]'),
          onTap: () {},
        ),
      ],
    );
  }
}
