import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text('Willkommen im Team-System!', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // Navigation zum Chat
              },
              icon: const Icon(Icons.chat),
              label: const Text('Messenger öffnen'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                // Navigation zum TeamPanel
              },
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('TeamPanel öffnen'),
            ),
          ],
        ),
      ),
    );
  }
}
