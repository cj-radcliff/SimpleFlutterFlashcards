import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _hostController;
  late TextEditingController _numberOfQuestionsController;
  bool _useApiLoader = true;
  final _myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController();
    _numberOfQuestionsController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _numberOfQuestionsController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hostController.text = prefs.getString('host') ?? 'http://localhost:8080';
      _useApiLoader = prefs.getBool('useApiLoader') ?? true;
      _numberOfQuestionsController.text = (prefs.getInt('numberOfQuestions') ?? 10).toString();
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('host', _hostController.text);
    await prefs.setBool('useApiLoader', _useApiLoader);
    await prefs.setInt('numberOfQuestions', int.parse(_numberOfQuestionsController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Quiz Server Host',
              ),
              enabled: true,
            ),
            TextField(
              controller: _numberOfQuestionsController,
              readOnly: false,
              enabled: true,
              
              decoration: const InputDecoration(
                labelText: 'Number of Questions',
              ),
              enableSuggestions: false,
             // enableInteractiveSelection: true,
              keyboardType: TextInputType.number,
            ),
            SwitchListTile(
              title: const Text('Use API Loader'),
              value: _useApiLoader,
              onChanged: (bool value) {
                setState(() {
                  _useApiLoader = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveSettings();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}