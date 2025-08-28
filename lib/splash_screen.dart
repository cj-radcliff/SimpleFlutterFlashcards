import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'questions_page.dart';
import 'settings_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/splash.png'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const QuestionsPage(title: 'Flutter Flashcards')),
                );
              },
              child: const Text('Start Quiz'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              child: const Text('Settings'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text('Exit'),
            ),
          ],
        ),
      ),
    );
  }
}
