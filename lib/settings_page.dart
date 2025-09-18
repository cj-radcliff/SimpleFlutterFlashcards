import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_question_loader.dart';
import 'package:dio/dio.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _hostController;
  late TextEditingController _numberOfQuestionsController;
  late TextEditingController _responseController;
  bool _useApiLoader = true;
  bool _isTesting = false;
  int _testCounter = 0;
  Timer? _testTimer;
  late ApiQuestionLoader _apiQuestionLoader;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController();
    _numberOfQuestionsController = TextEditingController();
    _responseController = TextEditingController();
    _loadSettings();
    _apiQuestionLoader = ApiQuestionLoader(Dio());
  }

  @override
  void dispose() {
    _hostController.dispose();
    _numberOfQuestionsController.dispose();
    _responseController.dispose();
    _testTimer?.cancel();
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

  void _toggleApiTest() {
    if (_isTesting) {
      _testTimer?.cancel();
      setState(() {
        _isTesting = false;
      });
    } else {
      setState(() {
        _isTesting = true;
        _testCounter = 0;
      });
      _testTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        _apiQuestionLoader.loadQuestions().then((questions) {
          setState(() {
            _testCounter++;
            final responseJson = questions.map((q) => q.toMap()).toList();
            _responseController.text = const JsonEncoder.withIndent('  ').convert(responseJson);
          });
        }).catchError((error) {
          setState(() {
            _responseController.text = error.toString();
          });
        });
      });
    }
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
                labelText: 'Quiz Server Host (Note: Change this from localhost to your own IP)',
              ),
              enabled: true,
              readOnly: false,
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleApiTest,
              child: Text(_isTesting ? 'Running API Test: $_testCounter' : 'Start API Test'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _responseController,
                maxLines: null,
                expands: true,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'API Response',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}